# README

## 启动 docker 环境

```bash
bash docker.sh
```

## 测试

进入 docker 环境或者在本地 ubuntu 环境：

```bash
# 普通表格
echo -e "A\tB\na\tb" | sh draw_table.sh

# 带标题的表格
echo -e "Module Log Analyse
Function Name\tCount
Function1\t20
Function2\t1113
Function3\t257
Function4\t113" | sh draw_table.sh

# 只有单列的表格
echo -e '1\n2\n3' | sh draw_table.sh

# 每列不同表格数
echo -e '1
1\t2
1\t2\t3
1\t2\t3\t4' | sh draw_table.sh

# 自定义颜色和样式
echo -e "Module Log Analyse
Function Name\tCount
Function1\t20
Function2\t1113
Function3\t257
Function4\t113" | sh draw_table.sh -15 -red,-white,-blue
```
