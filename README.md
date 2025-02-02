# righty

a set of powershell scripts which will be added automatically to your windows context menu (trial do not use this in production)

## Install

1. Open PowerShell with administrator privileges.
2. Run the following command to install Righty:

```powershell
# open powershell with administrator privileges
irm -Uri https://raw.githubusercontent.com/just-hms/righty/refs/heads/main/install.ps1 | iex
```

## How to use

After installation, you can access the Righty scripts directly from the context menu when right-clicking on a `.dwg` file. Follow these steps:

1. Right-click on a `.dwg` file
2. Select `Open with...` from the context menu.
3. Click on `Choose another app`.
4. In the "How do you want to open this file?" window:
  - Choose **More apps**.
  - Scroll down and click on **Look for another app on this PC**.
5. Navigate to the Righty folder (located where you installed the script).
6. Select the appropriate script (e.g., for the `.dwg` file you want to process) and click Open.
