package com.acorndelight;

import net.fabricmc.fabric.api.loot.v3.LootTableEvents;
import net.fabricmc.fabric.api.loot.v3.LootTableSource;

import net.minecraft.core.HolderLookup;
import net.minecraft.resources.ResourceKey;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.storage.loot.LootPool;
import net.minecraft.world.level.storage.loot.LootTable;
import net.minecraft.world.level.storage.loot.entries.EmptyLootItem;
import net.minecraft.world.level.storage.loot.entries.LootItem;
import net.minecraft.world.level.storage.loot.predicates.ExplosionCondition;
import net.minecraft.world.level.storage.loot.providers.number.ConstantValue;

/**
 * Makes breaking plain oak leaves drop an acorn 13% of the time.
 *
 * <p>The extra pool is injected with the loot API rather than by overriding vanilla's loot table
 * file, so it composes cleanly with other mods and datapacks that also touch oak leaves.
 */
public final class ModLootTables {
	private ModLootTables() {
	}

	/** Denominator the pool's weights add up to. */
	private static final int CHANCE_DENOMINATOR = 100;

	/** Chance, as a percentage, for a single oak-leaves block to additionally drop one acorn. */
	public static final int ACORN_DROP_CHANCE_PERCENT = 13;

	/** The same chance expressed as a fraction, for documentation and tests. */
	public static final float ACORN_DROP_CHANCE = ACORN_DROP_CHANCE_PERCENT / (float) CHANCE_DENOMINATOR;

	public static void initialize() {
		LootTableEvents.MODIFY.register((ResourceKey<LootTable> key, LootTable.Builder tableBuilder,
				LootTableSource source, HolderLookup.Provider registries) -> {
			if (key != Blocks.OAK_LEAVES.getLootTable().orElse(null)) {
				return;
			}

			// A pool holding a single entry would always drop, so the chance is expressed the
			// vanilla way: a weighted set of entries whose weights add up to CHANCE_DENOMINATOR,
			// with the leftover weight taken up by an empty entry.
			LootPool.Builder pool = LootPool.lootPool()
					.setRolls(ConstantValue.exactly(1.0f))
					.add(LootItem.lootTableItem(ModItems.ACORN)
							.setWeight(ACORN_DROP_CHANCE_PERCENT))
					.add(EmptyLootItem.emptyItem()
							.setWeight(CHANCE_DENOMINATOR - ACORN_DROP_CHANCE_PERCENT))
					.when(ExplosionCondition.survivesExplosion());

			tableBuilder.pool(pool.build());
		});
	}
}
