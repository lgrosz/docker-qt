# escape=`

# Builder image
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as builder

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Download msvc components
ADD https://aka.ms/vs/16/release/vs_community.exe C:\
RUN C:\vs_community.exe --quiet --wait --norestart --noUpdateInstaller `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --add Microsoft.VisualStudio.Component.Windows10SDK.18362 `
        --add Microsoft.VisualStudio.Component.VC.ATLMFC

# Download jom
ADD https://download.qt.io/official_releases/jom/jom_1_1_4.zip C:\
RUN Expand-Archive .\jom_1_1_4.zip -DestinationPath C:\jom

# Set environment
USER ContainerAdministrator
RUN setx /M PATH $('C:\jom;{0}' -f $env:PATH);
USER ContainerUser


# Build Qt stage
FROM builder as qt

ARG QT_CONFIGURE_EXTRA

ADD https://download.qt.io/archive/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz C:\qt-everywhere-src-5.15.0.tar.xz

# Install 7z
ADD https://www.7-zip.org/a/7z2301-x64.msi C:\
USER ContainerAdministrator
RUN Start-Process msiexec.exe -Wait -ArgumentList '/I C:\7z2301-x64.msi /quiet'
RUN setx /M PATH $('C:\Program Files\7-Zip;{0}' -f $env:PATH);
USER ContainerUser

# Extract with 7z
RUN 7z x -bsp2 C:\qt-everywhere-src-5.15.0.tar.xz
RUN 7z x -bsp2 C:\qt-everywhere-src-5.15.0.tar

WORKDIR C:\qt-everywhere-src-5.15.0

COPY --from=lgrosz/openssl:1.1.1w ["C:/Program Files/OpenSSL", "C:/Program Files/OpenSSL"]

ADD https://www.python.org/ftp/python/2.7.18/python-2.7.18.amd64.msi C:\
USER ContainerAdministrator
RUN Start-Process msiexec.exe -Wait -ArgumentList '/I C:\python-2.7.18.amd64.msi /quiet'
RUN setx /M PATH $('C:\Python27;{0}' -f $env:PATH);
USER ContainerUser

# Changing shells since vcvars64 is a batch script
SHELL ["cmd", "/S", "/C"]

# Configure Qt
# Build and install
RUN CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" `
      && .\configure `
            -openssl-runtime OPENSSL_INCDIR="C:/Program Files/OpenSSL/include" `
            -debug-and-release `
            -nomake examples `
            -nomake tests `
            -skip qtwebengine `
            -opensource `
            -prefix C:\Qt `
            %QT_CONFIGURE_EXTRA%

# Build
RUN CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" `
      && jom

# Install
RUN CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" `
      && jom install


# Main image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

COPY --from=qt C:\Qt C:\Qt

