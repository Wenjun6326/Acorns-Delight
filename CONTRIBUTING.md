# 参与开发 / Contributing

## 版本规范

版本号写在 `gradle.properties` 的 `version` 里，并**原样作为 Git Tag 使用**（Tag 名 == 版本号，例如 `1.1.0`）。

采用三段式 `X.Y.Z`：

| 版本 | 含义 | 例子 |
| --- | --- | --- |
| **X.Y.0** | **大改动**：加入全新机制或新玩法 | 新增「烤橡果」「橡果派」、加入烹饪锅配方、新的生物群系互动 |
| **X.Y.Z** | **小改动**：仅修复兼容性或优化问题 | 放宽 Loader 版本要求、适配 Minecraft 26.2、修复模组冲突、性能优化 |

* 两者都是「**可玩版本**」，都必须打 Tag。
* 开发过程中的中间提交**不打 Tag**。
* Tag 一旦推送就不要移动或删除——它是回滚和对比的依据。
* 小改动**不改变** `X.Y` 前缀：`1.1.0` 之后的小改动依次是 `1.1.1`、`1.1.2`；只有当出现新玩法时才升到 `1.2.0`。

### Fabric Loader 兼容性约定

`gradle.properties` 里有两个 Loader 相关字段，含义不同，别混淆：

| 字段 | 作用 |
| --- | --- |
| `loader_version` | **开发环境**实际使用的 Loader。刻意固定在**支持的最低版本**（当前 `0.18.4`），这样一旦代码误用了新版 Loader 才有的行为，会在本地 GameTest 里直接暴露，而不是等玩家崩溃。 |
| `min_loader_version` | 写进 `fabric.mod.json` 的 `depends.fabricloader`，即**玩家可用的最低 Loader**。 |

**下限由 Fabric API 决定**，不能随便往下降：当前 Fabric API `0.145.1+26.1` 自声明 `fabricloader >=0.18.4`，
而 26.1 可用的最老 Loader 也正是 `0.18.4`。升级 Fabric API 时记得重新核对这两个值，
核对方法：读 `fabric-api-<版本>.jar` 内 `fabric.mod.json` 的 `depends.fabricloader`。

## 发布流程

```bash
# 1. 改 gradle.properties 里的 version（例如 1.0 -> 1.1）
# 2. 更新 CHANGELOG.md，写清这个版本改了什么
# 3. 验证，必须全绿（否则不要发布）
./gradlew runGameTest build

# 4. 提交
git add -A
git commit -m "Release 1.1: 适配 Minecraft 26.2"

# 5. 打 Tag（Tag 名必须和 version 完全一致）并推送
git tag 1.1.1
git push origin main
git push origin 1.1.1
# 或者一次性推送所有标签：
# git push origin main --tags
```

### 发布前检查清单

- [ ] `gradle.properties` 的 `version` 已更新
- [ ] `CHANGELOG.md` 已更新
- [ ] `./gradlew runGameTest` 输出 `All 6 required tests passed :)`
- [ ] `./gradlew build` 成功，`build/libs/acorns-delight-<version>.jar` 存在
- [ ] 若升级了 Minecraft 版本，`minecraft_version`、`fabric_api_version`、`jei_version` 三者同步更新
      （JEI 每个 Minecraft 版本一个 artifact，换 MC 版本必须换 JEI 版本）
- [ ] 若升级了 Fabric API，重新核对 `min_loader_version`
- [ ] Tag 名与 `version` 一致，且已推送（`git push origin <tag>`）
- [ ] 在 GitHub 上建 Release 并**上传构建好的 jar**（不要只留一个 tag，玩家不会自己编译）

## 开发环境

| 组件 | 版本 |
| --- | --- |
| JDK | **25**（必须，26.1 要求） |
| Gradle | 9.5.1（wrapper 自带，无需安装） |
| Fabric Loom | 1.17.20 |
| Fabric Loader（开发用） | **0.18.4**（刻意用最低支持版本，见上文） |
| Fabric Loader（玩家最低） | 0.18.4 |
| Fabric Loader（当前稳定） | 0.19.5 |

常用命令：

```bash
./gradlew build          # 构建
./gradlew runGameTest    # 游戏内测试（CI 级别的验证）
./gradlew runServer      # 起一个开发用服务端
./gradlew runClient      # 起一个开发用客户端
```

> Loom 1.17 的 GameTest 任务名是 `runGameTest`（大写 T）。

## 26.1 特有的坑

26.1 是 Minecraft 首个**不混淆**版本，大量 API 与 1.21.x 不同。写代码前请注意：

* **没有 `mappings` 依赖行**；`modImplementation` / `remapJar` 改为 `implementation` / `jar`；插件 id 是
  `net.fabricmc.fabric-loom`（不再是 `fabric-loom`）。
* `ResourceLocation` → **`Identifier`**。
* `ItemGroupEvents` → **`CreativeModeTabEvents`**（包 `net.fabricmc.fabric.api.creativetab.v1`）；
  `FabricItemGroupEntries` → `FabricCreativeModeTabOutput`；`modifyEntriesEvent` → `modifyOutputEvent`。
* `CreativeModeTabs` 里的物品栏常量已经变成 **private**，不能再 `modifyOutputEvent(CreativeModeTabs.INGREDIENTS)`；
  请注册自己的物品栏。
* 注册物品必须调用 **`Item.Properties#setId(ResourceKey<Item>)`**，否则崩。
* 战利品表是**可重载的数据包注册表**，要从 `server.reloadableRegistries().getLootTable(key)` 取，
  而不是 `registryAccess().lookupOrThrow(...)`；`Registry.getOrThrow` 已改名 **`getValueOrThrow`**。
* 物品需要**两个** JSON：`assets/<ns>/items/<name>.json`（client item，必需，缺了会显示紫黑方块）
  和 `assets/<ns>/models/item/<name>.json`。合成配方目录是单数 `data/<ns>/recipe/`。
* **单个条目的战利品池必定掉落**——要做概率掉落必须用权重互补的条目
  （本项目用 13 : 87，空条目由 `EmptyLootItem` 提供）。这个坑曾经让掉落率变成 100%。

## 兼容性依赖说明

JEI、REI、Farmer's Delight 全部是 **compileOnly**（可选）依赖，不会打进成品 jar。

* `mezz.jei:jei-<mc>-fabric` 从 [BlameJared](https://maven.blamejared.com) 解析。
  注意其 `-fabric-api` artifact 在 26.1 上只是一个**空壳**，真正带 `mezz.jei.api` 类的是完整 jar。
* REI 在 26.1 **没有发布到任何 Maven 仓库**，因此 `libs/RoughlyEnoughItems-26.1.819.jar` 是随仓库
  携带的编译用 jar，来源与授权见 [`libs/README.md`](libs/README.md)。
* Farmer's Delight 走 Modrinth maven（`api.modrinth.com/maven`）。

运行时通过 `fabric.mod.json` 里的入口点加载（`jei_mod_plugin`、`rei_client`），
玩家没装对应模组时这些入口点不会被执行。
