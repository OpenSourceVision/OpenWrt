### 依赖
```
which gzip
which dd
which parted
```


# 切换到目录

```
cd /
```
### 解压缩镜像文件
gzip -kd xx.img.gz
```
gzip -kd
```
### 解压成功后删除压缩包，方便后面选择文件

### 扩展镜像文件的大小 (count=1024 表示增加 1024MB 的空间)
  dd if=/dev/zero bs=1M count=1024 >> xx.img
  
```
dd if=/dev/zero bs=1M count=1024 >>
```
### 使用分区工具操作镜像
parted xx.img
```
parted
```
### 查看分区情况
```
print
```
### 调整分区大小 (将第 2 个分区扩展至镜像文件的 100%)
```
resizepart 2 100%
```
### 查看是否扩展成功
```
print
```
###退出分区工具
```
quit
```
