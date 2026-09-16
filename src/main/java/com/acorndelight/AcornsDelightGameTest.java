package com.acorndelight;

import java.util.List;
import java.util.Optional;

import net.fabricmc.fabric.api.gametest.v1.GameTest;

import net.minecraft.core.BlockPos;
import net.minecraft.core.component.DataComponents;
import net.minecraft.core.registries.Registries;
import net.minecraft.gametest.framework.GameTestHelper;
import net.minecraft.resources.ResourceKey;
import net.minecraft.world.food.FoodProperties;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.component.Consumable;
import net.minecraft.world.item.crafting.CraftingInput;
import net.minecraft.world.item.crafting.CraftingRecipe;
import net.minecraft.world.item.crafting.RecipeHolder;
import net.minecraft.world.item.crafting.RecipeManager;
import net.minecraft.world.item.crafting.RecipeType;
import net.minecraft.world.level.GameType;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.storage.loot.LootParams;
import net.minecraft.world.level.storage.loot.LootTable;
import net.minecraft.world.level.storage.loot.parameters.LootContextParams;

/**
 * In-game verification of everything Acorn's Delight claims to do.
 *
 * <p>Run with {@code ./gradlew runGameTest}.
 */
public class AcornsDelightGameTest {
	private static final BlockPos TEST_POS = new BlockPos(1, 1, 1);

	// ---------------------------------------------------------------- recipes

	@GameTest
	public void acornJamRecipeRegisters(GameTestHelper helper) {
		RecipeManager recipes = helper.getLevel().getServer().getRecipeManager();
		ResourceKey<net.minecraft.world.item.crafting.Recipe<?>> key = ResourceKey.create(
				Registries.RECIPE, AcornsDelight.id("acorn_jam"));

		Optional<RecipeHolder<?>> found = recipes.byKey(key);
		helper.assertTrue(found.isPresent(), "recipe acorn_delight:acorn_jam was not loaded");
		helper.assertTrue(found.get().value() instanceof CraftingRecipe,
				"acorn_delight:acorn_jam is not a crafting recipe");

		helper.succeed();
	}

	/** Feeds the exact 3x3 layout from the recipe file through the real recipe manager. */
	@GameTest
	public void acornJamRecipeMatchesFourAcornsAndOneCocoaBean(GameTestHelper helper) {
		RecipeManager recipes = helper.getLevel().getServer().getRecipeManager();
		ResourceKey<net.minecraft.world.item.crafting.Recipe<?>> key = ResourceKey.create(
				Registries.RECIPE, AcornsDelight.id("acorn_jam"));

		// Acorns in the four corners, a single cocoa bean in the middle.
		CraftingInput input = CraftingInput.of(3, 3, List.of(
				new ItemStack(ModItems.ACORN), ItemStack.EMPTY, new ItemStack(ModItems.ACORN),
				ItemStack.EMPTY, new ItemStack(Items.COCOA_BEANS), ItemStack.EMPTY,
				new ItemStack(ModItems.ACORN), ItemStack.EMPTY, new ItemStack(ModItems.ACORN)));

		Optional<RecipeHolder<CraftingRecipe>> matched = recipes.getRecipeFor(
				RecipeType.CRAFTING, input, helper.getLevel());

		helper.assertTrue(matched.isPresent(), "4 acorns + 1 cocoa bean did not match any crafting recipe");
		helper.assertTrue(matched.get().id().equals(key),
				"4 acorns + 1 cocoa bean matched " + matched.get().id() + " instead of acorn_delight:acorn_jam");

		// The extra acorns that used to sit beside the cocoa bean must no longer be required.
		CraftingInput tooMany = CraftingInput.of(3, 3, List.of(
				new ItemStack(ModItems.ACORN), ItemStack.EMPTY, new ItemStack(ModItems.ACORN),
				new ItemStack(ModItems.ACORN), new ItemStack(Items.COCOA_BEANS), new ItemStack(ModItems.ACORN),
				new ItemStack(ModItems.ACORN), ItemStack.EMPTY, new ItemStack(ModItems.ACORN)));
		Optional<RecipeHolder<CraftingRecipe>> withSix = recipes.getRecipeFor(
				RecipeType.CRAFTING, tooMany, helper.getLevel());
		helper.assertTrue(withSix.isEmpty(),
				"the old 6-acorn layout still matches, so the recipe was not actually narrowed");

		helper.succeed();
	}

	// ------------------------------------------------------------------- food

	@GameTest
	public void acornJamFoodValues(GameTestHelper helper) {
		FoodProperties food = ModItems.ACORN_JAM.components().get(DataComponents.FOOD);
		helper.assertTrue(food != null, "acorn_jam has no FOOD component");

		helper.assertValueEqual(food.nutrition(), 4, "acorn_jam nutrition should be 4");
		helper.assertTrue(Math.abs(food.saturation() - 3.5f) < 1e-4f,
				"acorn_jam saturation should be 3.5 but was " + food.saturation());

		Consumable consumable = ModItems.ACORN_JAM.components().get(DataComponents.CONSUMABLE);
		helper.assertTrue(consumable != null, "acorn_jam has no CONSUMABLE component");

		// The acorn itself must stay inedible.
		helper.assertTrue(ModItems.ACORN.components().get(DataComponents.FOOD) == null,
				"acorn should not be edible");
		helper.succeed();
	}

	// ------------------------------------------------------------------ loot

	private static LootTable oakLeavesTable(GameTestHelper helper) {
		// Loot tables are a reloadable datapack registry in 26.1, so they are reached through the
		// server's ReloadableServerRegistries rather than through RegistryAccess.
		return helper.getLevel().getServer().reloadableRegistries()
				.getLootTable(ResourceKey.create(Registries.LOOT_TABLE,
						net.minecraft.resources.Identifier.withDefaultNamespace("blocks/oak_leaves")));
	}

	/** The context the game itself uses when a player breaks a block. */
	private static LootParams breakParams(GameTestHelper helper, LootTable table) {
		return new LootParams.Builder(helper.getLevel())
				.withParameter(LootContextParams.ORIGIN, helper.absolutePos(TEST_POS).getCenter())
				.withParameter(LootContextParams.TOOL, new ItemStack(Items.DIAMOND_PICKAXE))
				.withParameter(LootContextParams.BLOCK_STATE, Blocks.OAK_LEAVES.defaultBlockState())
				.withOptionalParameter(LootContextParams.THIS_ENTITY,
						helper.makeMockPlayer(GameType.SURVIVAL))
				.create(table.getParamSet());
	}

	private static long countAcorns(Iterable<ItemStack> stacks) {
		long found = 0;
		for (ItemStack stack : stacks) {
			if (stack.is(ModItems.ACORN)) {
				found += stack.getCount();
			}
		}
		return found;
	}

	/**
	 * The headline feature: breaking plain oak leaves drops an acorn roughly 13% of the time.
	 * Drives the real loot table 500 times and checks the observed rate.
	 */
	@GameTest(maxTicks = 200, setupTicks = 20)
	public void acornDropRateIsAboutThirteenPercent(GameTestHelper helper) {
		LootTable table = oakLeavesTable(helper);
		LootParams params = breakParams(helper, table);

		int rolls = 500;
		long acorns = 0;
		for (int i = 0; i < rolls; i++) {
			acorns += countAcorns(table.getRandomItems(params));
		}

		double rate = acorns / (double) rolls;
		// 500 independent 13% rolls have a standard deviation of ~1.5%, so +/-7% is a wide margin
		// that still fails loudly if the chance is wrong (for example 0% or 100%).
		helper.assertTrue(Math.abs(rate - 0.13) < 0.07,
				"observed acorn drop rate " + rate + " is far from the expected 0.13 (over " + rolls + " rolls)");
		helper.succeed();
	}

	/**
	 * Drives the exact path the game uses when a block is broken in the world
	 * ({@code Block.getDrops}, which is what {@code Level.destroyBlock} calls), so a mistake in the
	 * loot context or pool wiring cannot pass unnoticed.
	 */
	@GameTest(maxTicks = 200, setupTicks = 20)
	public void breakingOakLeavesDropsAcorns(GameTestHelper helper) {
		var state = Blocks.OAK_LEAVES.defaultBlockState();
		var level = helper.getLevel();
		BlockPos pos = helper.absolutePos(TEST_POS);
		var tool = new ItemStack(Items.DIAMOND_PICKAXE);

		int attempts = 300;
		long acorns = 0;
		for (int i = 0; i < attempts; i++) {
			acorns += countAcorns(net.minecraft.world.level.block.Block.getDrops(
					state, level, pos, null, null, tool));
		}

		helper.assertTrue(acorns > 0, "broke " + attempts + " oak leaves and never got an acorn");
		double rate = acorns / (double) attempts;
		helper.assertTrue(rate > 0.04 && rate < 0.25,
				"oak leaves dropped acorns at " + rate + ", expected roughly 0.13");
		helper.succeed();
	}
}
