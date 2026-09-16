# Acorn's Delight / 橡果的乐趣

一个面向 **Minecraft 26.1（Fabric）** 的小型农夫乐事风格扩展模组：橡树会掉橡果，橡果能做成果酱。

[![latest release](https://img.shields.io/github/v/release/Wenjun6326/Acorns-Delight?label=download&sort=semver)](https://github.com/Wenjun6326/Acorns-Delight/releases/latest)

---

## 添加的内容

| 物品 | 说明 |
| --- | --- |
| **橡果** | 普通物品，本身不可食用 |
| **橡果酱** | 食物：恢复 **4 点饱食度**、**3.5 点饱和度**，像喝药水一样饮用（1.6 秒） |

两者都会出现在专属的创造模式物品栏「橡果的乐趣」中。

## 怎么获得

### 橡果

破坏**普通橡树树叶**时有 **13% 概率**额外掉落 1 个橡果。

* 用剪刀或精准采集采集树叶**不会**掉落橡果。
* 被爆炸破坏的树叶也不会掉落。
* 下雨、时运附魔等不影响这个概率。

### 橡果酱

在工作台里用 **4 个橡果 + 2 颗可可豆**合成：

```
A . A          A = 橡果（四个角）
. C .          C = 可可豆（正中）
A . A
```

**橡果放在四个角，可可豆放在正中间。**

| 材料 | 数量 |
| --- | --- |
| 橡果 | **4** |
| 可可豆 | **1** |

## 安装

1. 安装 **Fabric Loader 0.18.4 或更高版本**（推荐直接用最新的
   [Fabric 安装器](https://fabricmc.net/use/installer/)，0.19.x / 0.20.x 都可用）。
2. 从 [Releases 页面](https://github.com/Wenjun6326/Acorns-Delight/releases/latest) 下载 jar，
   连同 [Fabric API](https://modrinth.com/mod/fabric-api) 一起放进 `.minecraft/mods`。
3. 启动游戏即可，无需额外配置。

### 运行要求

| | |
| --- | --- |
| Minecraft | 26.1（26.1.1 / 26.1.2 同样可用） |
| Fabric Loader | 0.18.4 或更高 |
| Fabric API | **必需** |
| Java | 25 |

## 兼容性

| 模组 | 状态 | 说明 |
| --- | --- | --- |
| **农夫乐事**（Farmer's Delight Refabricated） | ✅ 兼容 | 软依赖，不装也能正常玩 |
| **JEI** | ✅ 支持 | 自动收录橡果酱的合成配方 |
| **REI** | ✅ 支持 | 同上 |
| 其他农夫乐事附属 | ✅ 兼容 | 不占用公共 ID，也不改写原版文件 |

JEI 和 REI 都是**可选**的，不装不会报错。

## 常见问题

**挖了很多树叶都没掉橡果？**
13% 是每块树叶独立判定的概率，连续十几块不掉属于正常范围。挖一组（64 块）平均能拿到 8 个左右。

**和其他改树叶掉落的模组冲突吗？**
不会。本模组用战利品表事件追加一个独立掉落池，不覆盖原版的战利品表，所以可以共存。

**支持 Forge / NeoForge 吗？**
不支持，这是纯 Fabric 模组。

## 链接

* [更新日志](CHANGELOG.md)
* [下载最新版本](https://github.com/Wenjun6326/Acorns-Delight/releases/latest)
* [参与开发 / 自行构建](CONTRIBUTING.md)

## 许可

MIT，详见 [LICENSE](LICENSE)。
