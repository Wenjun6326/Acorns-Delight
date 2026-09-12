# 更新日志 / Changelog

仓库：<https://github.com/Wenjun6326/Acorns-Delight>

本文件记录每个**可玩版本**。版本号规则见 [CONTRIBUTING.md](CONTRIBUTING.md)：

* **X.Y.0** —— 大改动（全新机制或新玩法）
* **X.Y.Z** —— 小改动（仅修复兼容性或优化）

每个版本号都对应一个同名的 Git Tag。

---

## [1.1.1] — 2026-09-12

**小改动：贴图缩小一个像素。** 玩法、数值、兼容性与 1.1.0 完全一致。

### 变更

* 物品贴图内容等比缩小 1 像素，画布仍为 16×16，四周留白更均匀：
  * 橡果：内容由 **12×16** 变为 **11×15**
  * 橡果酱：内容由 **14×16** 变为 **13×15**
* 贴图由原始高清图（1254×1254）重新降采样生成，而不是从 16×16 再缩，避免二次重采样糊边。
* 模组图标同步重制。

---

## [1.1.0] — 2026-09-12

**小改动：放宽 Fabric Loader 版本要求。** 玩法与 1.0 完全一致，只是能在更多环境下启动。

### 修复

* **无法在 Fabric Loader 0.19.5 以下的版本启动。**
  `fabric.mod.json` 里把 `fabricloader` 要求写成了 `>=0.19.5`，远高于实际需要，
  导致使用 0.18.x / 0.19.0–0.19.4 的整合包与玩家被直接拒绝加载。

### 变更

* `depends.fabricloader` 由 `>=0.19.5` 放宽到 **`>=0.18.4`**。
  这是 26.1 可用的最老 Loader，也正是 Fabric API `0.145.1+26.1` 自声明的下限
  （`fabricloader >=0.18.4`），因此无法再往下降。
* 开发环境（`gradle.properties` 的 `loader_version`）同步改为 **0.18.4**，
  即**刻意用最低支持的 Loader 开发和跑测试**——这样一旦代码误用了新版 Loader 才有的行为，
  会在本地 GameTest 直接失败，而不是等玩家崩溃。
* 新增 `min_loader_version` 字段，供 `fabric.mod.json` 模板引用，避免两处版本号不同步。

### 验证

* `Loading Minecraft 26.1 with Fabric Loader 0.18.4` → **6 个 GameTest 全部通过**。
* 构建产物 `acorns-delight-1.1.0.jar` 内 `fabric.mod.json` 已确认为 `fabricloader >=0.18.4`。

---

## [1.0] — 2026-09-12

首个可玩版本。面向 **Minecraft 26.1（Fabric）**。

### 新增

* **橡果 `acorn_delight:acorn`**
  * 破坏普通橡树树叶（`minecraft:oak_leaves`）时有 **13%** 概率额外掉落 1 个。
  * 通过 Fabric `LootTableEvents.MODIFY` 注入独立掉落池，**不覆盖**原版战利品表，可与其他修改橡树树叶的模组或数据包共存（13 : 87 权重，空条目补足余量）。
  * 掉落池带 `survives_explosion` 条件；用剪刀或精准采集采集树叶不会掉落橡果。
* **橡果酱 `acorn_delight:acorn_jam`**
  * 工作台合成：4 个橡果 + 2 颗可可豆（橡果在四角，可可豆在剩余两格）。
  * 食用恢复 **4 点饱食度** 与 **3.5 点饱和度**，按饮料方式饮用（1.6 秒）。
* 专属创造模式物品栏「橡果的乐趣」。
* 中英文本地化（`zh_cn` / `en_us`）。

### 兼容

* **JEI**：`jei_mod_plugin` 入口点，橡果酱配方自动收录。
* **REI**：`rei_client` 入口点，配方自动收录。
* **Farmer's Delight Refabricated**：`recommends` 软依赖，不冲突。
* JEI / REI 均为可选依赖，未安装时不会加载对应入口点。

### 技术说明

* 26.1 是 Minecraft 首个**不混淆**版本：使用 Mojang 官方名称开发，`build.gradle` 中无 `mappings` 依赖行，`modImplementation` / `remapJar` 改为 `implementation` / `jar`。
* 工具链：JDK 25、Gradle 9.5.1、Fabric Loom 1.17.20、Fabric Loader 0.19.5、Fabric API 0.145.1+26.1。
* 自带 6 个游戏内测试（GameTest），`./gradlew runGameTest` 全绿。

### 修复

* 修复掉落率错误：最初战利品池只放了单个条目，而**单条目池必定掉落**，实际概率为 100% 而非 13%。由 GameTest 发现，改为加入权重互补的空条目（13 : 87）后修正。
