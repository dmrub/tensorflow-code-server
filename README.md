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

## Used resources

 * https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/base/Dockerfile
 * https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/codeserver/Dockerfile
 * https://github.com/linuxserver/docker-code-server
