# Setup

Here are some tips for your fresh Windows 10 installation.

## Full-disk Encryption

### VeraCrypt
!!! Tip
    I recommend to use [VeraCrypt](https://www.veracrypt.fr/). It offers much more configuration options than BitLocker and is not limited to certain variants of Windows.

VeraCrypt is a successor of the well known TrueCrypt cryptography software. It can be used without a Trusted Platform Module (TPM).

Take a look at the [VeraCrypt Documentation](https://www.veracrypt.fr/en/Documentation.html) before starting.

### BitLocker

BitLocker is the Full-disk-encryption solution from Microsoft for Windows installations. A Trusted Platform Module (TPM) is required that you can enable BitLocker without any further configuration. The keys to decrypt the disk are normally stored in the TPM. They can not be extracted from this separate chip.

#### Without TPM

If your mainboard does not have a TPM, you need to enter a passphrase before the system boots. This has to be enabled explicitly.

1. Use `Windows Key + R` and open `gpedit.msc`.
2. Find **Computer Configuration** > **Administrative Templates** > **Windows Components** > **BitLocker Drive Encryption** > **Operating System Drives** in the tree view on the left side of the window.
   ![Screenshot: gpedit.msc](files/bitlocker-no-tpm-1.png)
3. Double-click on **Require additional authentication at startup** on the right side of the window.
4. Select **Enabled** and make sure to check the **Allow BitLocker without a compatible TPM (required a password or a startup key on a USB flash drive)**. Click **OK**.
   ![Screenshot: additional authentication at startup](files/bitlocker-no-tpm-2.jpg)
5. You can enable BitLocker for all drives you want.


## YubiKey SmartCard

The YubiKey can be configured to store three different PGP keys to encrypt, sign and authenticate. The keys cannot be read from the YubiKey by anyone. Every cryptographic operation is performed directly on the YubiKey itself so that the PGP private key never has to leave the device.

Follow the steps below to configure a Windows 10 system for use with a YubiKey SmartCard for SSH and git commit signing.

!!! note
    This guide does not cover how to configure your YubiKey with PGP Keys.

1. Install [GPG4Win](https://www.gpg4win.org/) and [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html).
2. Open the application **Kleopatra**, open the menu **Tools** > **Manage Smartcards** and check if your YubiKey is recognized correctly. You may have to press F5 to refresh the view.
3. Open the settings for Kleopatra and go to **GnuPG System**. Under the tab **Private Keys**, make sure that **Enable ssh support** and **Enable putty support** is checked.   
4. Add the environment variable `GIT_SSH=C:\Program Files\PuTTY\plink.exe`.
5. Set `gpg.program` value for the global git config in your PowerShell for commit signing.
   ```PowerShell
   git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
   ```

!!! note
    If you are using git bash, commit signing does not work! It is recommended to use PowerShell in Windows instead.

!!! tip
    You you are using Git Bash in Windows, you may connect to the git hosting service with PuTTY first so that you can add the server key as trusted.


## YubiKey Windows Login

The YubiKey can be used as a 2nd factor for user login.
For instructions please see [YubiKey Windwos Logon Configuration Guide](https://support.yubico.com/support/solutions/articles/15000006459-windows-logon-tool-configuration-guide).
