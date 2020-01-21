# Sphinx 文档说明

## 安装环境

```bash
python3 -m pip install sphinx sphinx-autobuild sphinx_rtd_theme recommonmark
```

## 开始

1. 使用 `sphinx-quickstart` 创建一个空的模板。
2. 允许生成 `build`，`source` 文件夹。
3. 修改 `source/conf.py` 配置信息。

## 运行编译

使用命令运行编译，在 `build` 文件中生成效果文档，可预览或者上传发布html。

```bash
make html
```