# github-action-demo


#### Storing large secrets
To use secrets that are larger than 64 KB, you can use a workaround to store encrypted secrets in your repository and save the decryption passphrase as a secret on GitHub. For example, you can use gpg to encrypt a file containing your secret locally before checking the encrypted file in to your repository on GitHub. For more information, see the "gpg manpage."

```
Warning: Be careful that your secrets do not get printed when your workflow runs. When using this workaround, GitHub does not redact secrets that are printed in logs.
```

+ Run the following command from your terminal to encrypt the file containing your secret using gpg and the AES256 cipher algorithm. In this example, my_secret.json is the file containing the secret.

```
gpg --symmetric --cipher-algo AES256 my_secret.json
```

+ You will be prompted to enter a passphrase. Remember the passphrase, because you'll need to create a new secret on GitHub that uses the passphrase as the value.

+ Create a new secret that contains the passphrase. For example, create a new secret with the name LARGE_SECRET_PASSPHRASE and set the value of the secret to the passphrase you used in the step above.

+ Copy your encrypted file to a path in your repository and commit it. In this example, the encrypted file is my_secret.json.gpg.

```
Warning: Make sure to copy the encrypted my_secret.json.gpg file ending with the .gpg file extension, and not the unencrypted my_secret.json file.
```

```
git add my_secret.json.gpg
git commit -m "Add new encrypted secret JSON file"
```

+ Create a shell script in your repository to decrypt the secret file. In this example, the script is named decrypt_secret.sh.

```
#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$LARGE_SECRET_PASSPHRASE" \
--output $HOME/secrets/my_secret.json my_secret.json.gpg
```

+ Ensure your shell script is executable before checking it in to your repository.

```
chmod +x decrypt_secret.sh
git add decrypt_secret.sh
git commit -m "Add new decryption script"
git push
```

+ In your GitHub Actions workflow, use a step to call the shell script and decrypt the secret. To have a copy of your repository in the environment that your workflow runs in, you'll need to use the actions/checkout action. Reference your shell script using the run command relative to the root of your repository.

```
name: Workflows with large secrets

on: push

jobs:
  my-job:
    name: My Job
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Decrypt large secret
        run: ./decrypt_secret.sh
        env:
          LARGE_SECRET_PASSPHRASE: ${{ secrets.LARGE_SECRET_PASSPHRASE }}
      # This command is just an example to show your secret being printed
      # Ensure you remove any print statements of your secrets. GitHub does
      # not hide secrets that use this workaround.
      - name: Test printing your secret (Remove this step in production)
        run: cat $HOME/secrets/my_secret.json
```