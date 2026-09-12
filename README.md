# Acorn's Delight / 姗℃灉鐨勪箰瓒?
浠撳簱鍦板潃锛?https://github.com/Wenjun6326/Acorns-Delight>

涓€涓潰鍚?**Minecraft 26.1锛團abric锛?* 鐨勫皬鍨嬪啘澶箰浜嬮鏍兼墿灞曟ā缁勩€?
> 娉ㄦ剰锛?6.1 鏄?Minecraft 鍘嗗彶涓?*绗竴涓笉娣锋穯锛坲nobfuscated锛?*鐨勭増鏈€?> 鍥犳鏈」鐩娇鐢?**Mojang 瀹樻柟鍚嶇О**寮€鍙戯紝涓嶅啀浣跨敤 Yarn 鏄犲皠锛沗build.gradle` 涓篃娌℃湁
> `mappings` 渚濊禆琛岋紝`modImplementation` / `remapJar` 宸插垎鍒敼涓?`implementation` / `jar`銆?
褰撳墠鐗堟湰锛?*1.0** 锝?鏇存柊鍐呭瑙?[CHANGELOG.md](CHANGELOG.md) 锝?鍙備笌寮€鍙戜笌鍙戝竷娴佺▼瑙?[CONTRIBUTING.md](CONTRIBUTING.md)

---

## 鍐呭

| 鐗╁搧 | 璇存槑 |
| --- | --- |
| `acorn_delight:acorn` 姗℃灉 | 鏅€氱墿鍝侊紝涓嶅彲椋熺敤 |
| `acorn_delight:acorn_jam` 姗℃灉閰?| 椋熺墿锛屾仮澶?**4 鐐归ケ椋熷害** 涓?**3.5 鐐归ケ鍜屽害**锛岄ギ鐢ㄨ€楁椂 1.6 绉?|

### 鑾峰彇鏂瑰紡

* **姗℃灉**锛氱牬鍧忔櫘閫氭鏍戞爲鍙讹紙`minecraft:oak_leaves`锛夋椂鏈?**13% 姒傜巼**棰濆鎺夎惤 1 涓€?  * 閫氳繃 Fabric 鐨?`LootTableEvents.MODIFY` 娉ㄥ叆涓€涓嫭绔嬫帀钀芥睜瀹炵幇锛?*涓嶈鐩?*鍘熺増鎴樺埄鍝佽〃锛?    鍥犳鍙互鍜屽叾浠栦慨鏀规鏍戞爲鍙剁殑妯＄粍 / 鏁版嵁鍖呭叡瀛樸€?  * 鎺夎惤姹犲甫 `survives_explosion` 鏉′欢锛氳鐖嗙偢鐮村潖鐨勬爲鍙朵笉浼氭帀钀芥鏋溿€?  * 鐢ㄥ壀鍒€鎴栫簿鍑嗛噰闆嗛噰闆嗘爲鍙朵笉浼氭帀钀芥鏋滐紙鍘熺増绗竴鎺夎惤姹犲懡涓悗鍗充腑姝㈠悗缁睜锛夈€?* **姗℃灉閰?*锛氬伐浣滃彴鍚堟垚 鈥斺€?4 涓鏋?+ 2 棰楀彲鍙眴銆?
```
A . A          A = 姗℃灉 (acorn_delight:acorn)
A C A          C = 鍙彲璞?(minecraft:cocoa_beans)
A . A
```

## 鍏煎鎬?
| 妯＄粍 | 鐘舵€?| 璇存槑 |
| --- | --- | --- |
| **Farmer's Delight Refabricated** | 鉁?鍏煎 | 鏈ā缁勫彧浣跨敤鍘熺増鐗╁搧涓庢爣鍑嗘暟鎹寘鏍煎紡锛屼笖閫氳繃鎴樺埄鍝佽〃浜嬩欢娉ㄥ叆鎺夎惤锛屼笉浼氫笌鍏跺啿绐併€俙fabric.mod.json` 涓０鏄庝负 `recommends`锛堣蒋渚濊禆锛夈€?|
| **JEI** (`jei`) | 鉁?鏀寔 | 鎻愪緵 `jei_mod_plugin` 鍏ュ彛鐐广€傛鏋滈叡鏄爣鍑嗙殑鏈夊簭鍚堟垚閰嶆柟锛孞EI 浼氳嚜鍔ㄦ敹褰曞苟鏄剧ず銆?|
| **REI** (`roughlyenoughitems`) | 鉁?鏀寔 | 鎻愪緵 `rei_client` 鍏ュ彛鐐广€傚悓鏍风敱 REI 鑷姩鏄剧ず鍚堟垚閰嶆柟銆?|
| 鍏朵粬鍐滃か涔愪簨闄勫睘 | 鉁?鍏煎 | 鏈崰鐢ㄤ换浣曞叕鍏?ID锛屼篃鏈敼鍐欏師鐗堟枃浠躲€?|

JEI / REI 鍧囦负**鍙€?*渚濊禆锛氭湭瀹夎鏃跺搴旂殑鍏ュ彛鐐逛笉浼氳鍔犺浇锛屾父鎴忎笉浼氭姤閿欍€?
## 鏋勫缓

闇€瑕?**JDK 25**锛圙radle 浼氫娇鐢?toolchain 25锛夈€?
```bash
./gradlew build
```

浜х墿锛歚build/libs/acorns-delight-1.0.jar`

### 鑷姩鍖栭獙璇?
妯＄粍鑷甫 6 涓?**娓告垙鍐呮祴璇曪紙GameTest锛?*锛屼細鍦ㄧ湡瀹炵殑 Minecraft 鏈嶅姟绔噷楠岃瘉鎺夎惤鐜囥€侀厤鏂逛笌椋熺墿鏁板€硷細

```bash
./gradlew runGameTest
```

閫氳繃鏃惰緭鍑?`All 6 required tests passed :)`銆傝鐩栧唴瀹癸細

1. `acorn_delight:acorn_jam` 閰嶆柟琚纭姞杞斤紱
2. 3脳3 宸ヤ綔鍙颁腑銆? 姗℃灉 + 2 鍙彲璞嗐€嶈兘鍖归厤鍒拌閰嶆柟锛?3. 姗℃灉閰遍ケ椋熷害涓?4銆侀ケ鍜屽害涓?3.5锛堢簿纭牎楠岋級锛?4. 姗℃灉鏈韩涓嶅彲椋熺敤锛?5. 姗℃爲鏍戝彾鐨勬帀钀借〃涓‘瀹炲寘鍚鏋滄潯鐩紱
6. 椹卞姩鎺夎惤琛?500 娆″苟鏂█瑙傛祴鎺夎惤鐜囨帴杩?13%锛屽悓鏃剁敤 `Block.getDrops` 璧颁竴閬嶆父鎴忕湡瀹炵殑鐮村潖鏂瑰潡璺緞銆?
> 杩欏娴嬭瘯鍦ㄥ紑鍙戜腑纭疄鎶撳埌浜嗕竴涓?bug锛氭渶鍒濇垬鍒╁搧姹犻噷鍙斁浜嗕竴涓潯鐩紝鑰?*鍗曟潯鐩睜蹇呭畾鎺夎惤**锛?> 瀵艰嚧瀹為檯姒傜巼鏄?100% 鑰岄潪 13%銆備慨姝ｆ柟寮忔槸琛ヤ笂涓€涓潈閲嶄簰琛ョ殑绌烘潯鐩紙13 : 87锛夈€?
### 宸ュ叿閾剧増鏈?
| 缁勪欢 | 鐗堟湰 |
| --- | --- |
| Minecraft | 26.1锛坄fabric.mod.json` 澹版槑 `~26.1`锛屽洜姝?26.1 / 26.1.1 / 26.1.2 閮藉彲杩愯锛?|
| Fabric Loader | 0.19.5 |
| Fabric API | 0.145.1+26.1 |
| Fabric Loom | 1.17.20锛坄net.fabricmc.fabric-loom`锛?|
| Gradle | 9.5.1 |
| Java | 25 |

## 瀹夎

1. 瀹夎 Fabric Loader 0.19.5 鍙婁互涓娿€?2. 灏?`acorns-delight-1.0.jar` 涓?[Fabric API](https://modrinth.com/mod/fabric-api) 鏀惧叆 `.minecraft/mods`銆?3. 鍙€夛細涓€璧锋斁鍏?Farmer's Delight Refabricated銆丣EI 鎴?REI銆?
## 鍙戝竷鍒?GitHub

浠撳簱缁存姢鑰呴娆″彂甯冩椂杩愯锛堝彧闇€涓€娆★紝涔嬪悗鐢ㄦ櫘閫氱殑 `git push` 鍗冲彲锛夛細

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\init-github.ps1
```

鑴氭湰浼氬垱寤?GitHub 浠撳簱銆佹帹閫?`main` 涓庡叏閮ㄦ爣绛撅紝骞舵妸鐪熷疄浠撳簱鍦板潃鍥炲～鍒版湰鏂囦欢涓?`CHANGELOG.md`銆?瀹?*鍙渶瑕?git 鍜屼竴涓?GitHub Token**锛屼笉闇€瑕佸畨瑁?GitHub CLI锛堥儴鍒嗙綉缁滀細灞忚斀 GitHub 鐨勭綉椤?涓嬭浇鍩熷悕锛?浣?git 涓?api.github.com 閫氬父鍙敤锛夈€俆oken 浠呯敤浜庢湰娆℃帹閫侊紝涓嶄細鍐欏叆纾佺洏銆?
鍚庣画鐗堟湰鍙戝竷娴佺▼瑙?[CONTRIBUTING.md](CONTRIBUTING.md)銆?
## 椤圭洰缁撴瀯

```
src/main/java/com/acorndelight/
鈹溾攢鈹€ AcornsDelight.java              妯＄粍鍏ュ彛
鈹溾攢鈹€ ModItems.java                   鐗╁搧娉ㄥ唽锛堝惈姗℃灉閰辩殑椋熺墿灞炴€э級
鈹溾攢鈹€ ModCreativeTabs.java            鍒涢€犳ā寮忕墿鍝佹爮
鈹溾攢鈹€ ModLootTables.java              姗℃爲鏍戝彾 13% 鎺夎惤姗℃灉
鈹斺攢鈹€ compat/
    鈹溾攢鈹€ jei/AcornsDelightJeiPlugin.java
    鈹斺攢鈹€ rei/AcornsDelightReiPlugin.java

src/main/resources/
鈹溾攢鈹€ fabric.mod.json
鈹溾攢鈹€ assets/acorn_delight/{items,models/item,textures/item,lang}/
鈹斺攢鈹€ data/acorn_delight/recipe/acorn_jam.json
```

### 鍏充簬 `items/*.json` 涓?`models/item/*.json`

鑷?1.21.4 璧凤紝涓€涓墿鍝侀渶瑕?*涓や釜** JSON 鏂囦欢锛?
* `assets/<ns>/items/<name>.json` 鈥斺€?"client item" / 鐗╁搧妯″瀷瀹氫箟锛堝繀闇€锛岀己澶卞垯鐗╁搧鏄剧ず涓虹传榛戞柟鍧楋級
* `assets/<ns>/models/item/<name>.json` 鈥斺€?浼犵粺鐗╁搧妯″瀷锛岀埗绾?`minecraft:item/generated`

## 璐村浘

`textures/item/acorn.png` 涓?`acorn_jam.png` 鐢辩敤鎴锋彁渚涚殑楂樺垎杈ㄧ巼鍘熷浘闄嶉噰鏍蜂负 **16脳16** 鍒舵垚銆?`icon.png` 鐢辨鏋滆创鍥句互鏈€杩戦偦鏀惧ぇ鐢熸垚銆?
## 璁稿彲

MIT锛岃瑙?`LICENSE`銆?`libs/` 鐩綍涓嬩粎鐢ㄤ簬缂栬瘧鐨?REI jar 鐗堟潈褰掑師浣滆€呮墍鏈夛紝璇﹁ `libs/README.md`銆?