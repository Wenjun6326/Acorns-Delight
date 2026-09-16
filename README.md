# Acorn's Delight / 橡果的乐趣

仓库地址：<https://github.com/Wenjun6326/Acorns-Delight>

一个面向 **Minecraft 26.1（Fabric）** 的小型农夫乐事风格扩展模组。

> 注意：26.1 是 Minecraft 历史上**第一个不混淆（unobfuscated）**的版本。
> 因此本项目使用 **Mojang 官方名称**开发，不再使用 Yarn 映射；`build.gradle` 中也没有
> `mappings` 依赖行，`modImplementation` / `remapJar` 已分别改为 `implementation` / `jar`。

当前版本：**1.1.0** ｜ [下载最新版](../../releases/latest) ｜ 更新内容见 [CHANGELOG.md](CHANGELOG.md) ｜ 参与开发与发布流程见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 内容

| 物品 | 说明 |
| --- | --- |
| `acorn_delight:acorn` 橡果 | 普通物品，不可食用 |
| `acorn_delight:acorn_jam` 橡果酱 | 食物，恢复 **4 点饱食度** 与 **3.5 点饱和度**，饮用耗时 1.6 秒 |

### 获取方式

* **橡果**：破坏普通橡树树叶（`minecraft:oak_leaves`）时有 **13% 概率**额外掉落 1 个。
  * 通过 Fabric 的 `LootTableEvents.MODIFY` 注入一个独立掉落池实现，**不覆盖**原版战利品表，
    因此可以和其他修改橡树树叶的模组 / 数据包共存。
  * 掉落池带 `survives_explosion` 条件：被爆炸破坏的树叶不会掉落橡果。
  * 用剪刀或精准采集采集树叶不会掉落橡果（原版第一掉落池命中后即中止后续池）。
* **橡果酱**：工作台合成 —— 4 个橡果 + 2 颗可可豆。

```
A . A          A = 橡果 (acorn_delight:acorn)
A C A          C = 可可豆 (minecraft:cocoa_beans)
A . A
```

## 兼容性

| 模组 | 状态 | 说明 |
| --- | --- | --- |
| **Farmer's Delight Refabricated** | ✅ 兼容 | 本模组只使用原版物品与标准数据包格式，且通过战利品表事件注入掉落，不会与其冲突。`fabric.mod.json` 中声明为 `recommends`（软依赖）。 |
| **JEI** (`jei`) | ✅ 支持 | 提供 `jei_mod_plugin` 入口点。橡果酱是标准的有序合成配方，JEI 会自动收录并显示。 |
| **REI** (`roughlyenoughitems`) | ✅ 支持 | 提供 `rei_client` 入口点。同样由 REI 自动显示合成配方。 |
| 其他农夫乐事附属 | ✅ 兼容 | 未占用任何公共 ID，也未改写原版文件。 |

JEI / REI 均为**可选**依赖：未安装时对应的入口点不会被加载，游戏不会报错。

## 构建

需要 **JDK 25**（Gradle 会使用 toolchain 25）。

```bash
./gradlew build
```

产物：`build/libs/acorns-delight-1.0.jar`

### 自动化验证

模组自带 6 个 **游戏内测试（GameTest）**，会在真实的 Minecraft 服务端里验证掉落率、配方与食物数值：

```bash
./gradlew runGameTest
```

通过时输出 `All 6 required tests passed :)`。覆盖内容：

1. `acorn_delight:acorn_jam` 配方被正确加载；
2. 3×3 工作台中「4 橡果 + 2 可可豆」能匹配到该配方；
3. 橡果酱饱食度为 4、饱和度为 3.5（精确校验）；
4. 橡果本身不可食用；
5. 橡树树叶的掉落表中确实包含橡果条目；
6. 驱动掉落表 500 次并断言观测掉落率接近 13%，同时用 `Block.getDrops` 走一遍游戏真实的破坏方块路径。

> 这套测试在开发中确实抓到了一个 bug：最初战利品池里只放了一个条目，而**单条目池必定掉落**，
> 导致实际概率是 100% 而非 13%。修正方式是补上一个权重互补的空条目（13 : 87）。

### 工具链版本

| 组件 | 版本 |
| --- | --- |
| Minecraft | 26.1（`fabric.mod.json` 声明 `~26.1`，因此 26.1 / 26.1.1 / 26.1.2 都可运行） |
| Fabric Loader（最低要求） | **0.18.4**（26.1 可用的最老 Loader，也正是 Fabric API 的下限） |
| Fabric Loader（开发环境） | 0.18.4（刻意用最低版本，见 [CONTRIBUTING.md](CONTRIBUTING.md)） |
| Fabric API | 0.145.1+26.1 |
| Fabric Loom | 1.17.20（`net.fabricmc.fabric-loom`） |
| Gradle | 9.5.1 |
| Java | 25 |

## 安装

1. 安装 **Fabric Loader 0.18.4 或更高**（0.19.x、0.20.x 等新版同样可用）。
   推荐直接用最新的 [Fabric 安装器](https://fabricmc.net/use/installer/)。
2. 将 `acorns-delight-1.1.0.jar` 与 [Fabric API](https://modrinth.com/mod/fabric-api) 放入 `.minecraft/mods`。
3. 可选：一起放入 Farmer's Delight Refabricated、JEI 或 REI。

> 也可以直接在 [Releases](../../releases) 页面下载已编译好的 jar，无需自己构建。

## 发布到 GitHub

仓库维护者首次发布时运行（只需一次，之后用普通的 `git push` 即可）：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\init-github.ps1
```

脚本会创建 GitHub 仓库、推送 `main` 与全部标签，并把真实仓库地址回填到本文件与 `CHANGELOG.md`。
它**只需要 git 和一个 GitHub Token**，不需要安装 GitHub CLI（部分网络会屏蔽 GitHub 的网页/下载域名，
但 git 与 api.github.com 通常可用）。Token 仅用于本次推送，不会写入磁盘。

后续版本发布流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 项目结构

```
src/main/java/com/acorndelight/
├── AcornsDelight.java              模组入口
├── ModItems.java                   物品注册（含橡果酱的食物属性）
├── ModCreativeTabs.java            创造模式物品栏
├── ModLootTables.java              橡树树叶 13% 掉落橡果
└── compat/
    ├── jei/AcornsDelightJeiPlugin.java
    └── rei/AcornsDelightReiPlugin.java

src/main/resources/
├── fabric.mod.json
├── assets/acorn_delight/{items,models/item,textures/item,lang}/
└── data/acorn_delight/recipe/acorn_jam.json
```

### 关于 `items/*.json` 与 `models/item/*.json`

自 1.21.4 起，一个物品需要**两个** JSON 文件：

* `assets/<ns>/items/<name>.json` —— "client item" / 物品模型定义（必需，缺失则物品显示为紫黑方块）
* `assets/<ns>/models/item/<name>.json` —— 传统物品模型，父级 `minecraft:item/generated`

## 贴图

`textures/item/acorn.png` 与 `acorn_jam.png` 由用户提供的高分辨率原图降采样为 **16×16** 制成。
`icon.png` 由橡果贴图以最近邻放大生成。

## 许可

MIT，详见 `LICENSE`。
`libs/` 目录下仅用于编译的 REI jar 版权归原作者所有，详见 `libs/README.md`。
