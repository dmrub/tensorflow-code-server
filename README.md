# tensorflow-code-server
tensorflow-code-server is a container image which adds to the tensorflow image a [code-server](https://github.com/coder/code-server) layer which runs [VS Code](https://github.com/Microsoft/vscode). Also it includes many useful tools for convinient development.

## Building

```sh
./docker-build.sh
```

## Running

```sh
./docker-run.sh
```

## Configuration
### Available Environment Variables

 - **DEFAULT_WORKSPACE**: Workspace directory to open by default.
 - **PASSWORD**: Optional Web UI password; if neither `PASSWORD` nor `HASHED_PASSWORD` are specified, no authentication will occur.
 - **HASHED_PASSWORD**: Optional web UI password, overrides `PASSWORD`, see below for instructions on how to create it.

## Create Hashed Password

### With Node.js

https://github.com/cdr/code-server/blob/master/docs/FAQ.md#can-i-store-my-password-hashed

### With Python
```sh
pip install argon2-cffi
python3 -c 'import sys; from argon2 import PasswordHasher; ph = PasswordHasher(); import getpass; p = getpass.getpass(); r = getpass.getpass("Retype password: "); print(ph.hash(p)) if p == r else print("Sorry passwords do not match", file=sys.stderr)'
```

## Used Resources

 * https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/base/Dockerfile
 * https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/codeserver/Dockerfile
 * https://github.com/linuxserver/docker-code-server
