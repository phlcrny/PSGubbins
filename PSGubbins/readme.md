# PSGubbins

A Powershell module of assorted gubbins that didn't really fit anywhere else.

As the name suggests, this is at best a work in progress. Feel free to report issues or suggest improvements.

## Getting Started

```Powershell
Install-Module PSGubbins

Import-Module PSGubbins

Get-Command -Module PSGubbbins
```

If the Powershell Gallery isn't an option, you can clone or download the source code directly from GitHub, and install manually.

```Powershell
# Clone from GitHub
git clone https://github.com/phlcrny/PSGubbins.git
# Change to the root of the project
cd PSGubbins
# Copy the built module to the PSModulePath for all users
Copy-Item PSGubbins "C:\Program Files\WindowsPowerShell\Modules" -Recurse
# Or for pwsh
Copy-Item PSGubbins "C:\Program Files\PowerShell\Modules" -Recurse
```
