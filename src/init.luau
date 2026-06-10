--!strict

local Types = require(script.Types)

local function merge(...: Types.Props): Types.Props
	local result: Types.Props = {}

	for _, source in ipairs({ ... }) do
		if type(source) == "table" then
			for key, value in pairs(source) do
				result[key] = value
			end
		end
	end

	return result
end

local function matchesCompound(
	compound: Types.CompoundVariant,
	selectedVariants: { [string]: string | boolean | number }
): boolean
	for key, value in pairs(compound) do
		if key ~= "props" then
			if selectedVariants[key] ~= value then
				return false
			end
		end
	end

	return true
end

local function getVariantOrder(variants: Types.VariantMap, explicitOrder: { string }?): { string }
	local order = {}
	local included = {}

	for _, variantName in ipairs(explicitOrder or {}) do
		if variants[variantName] ~= nil and not included[variantName] then
			table.insert(order, variantName)
			included[variantName] = true
		end
	end

	local remaining = {}
	for variantName in pairs(variants) do
		if not included[variantName] then
			table.insert(remaining, variantName)
		end
	end
	table.sort(remaining)

	for _, variantName in ipairs(remaining) do
		table.insert(order, variantName)
	end

	return order
end

local function cva(baseProps: Types.Props, options: Types.CvaOptions?): Types.CvaFunction
	options = options or {}

	return function(overrides: Types.Props?): Types.Props
		overrides = overrides or {}

		local variants = options.variants or {}
		local variantOrder = getVariantOrder(variants, options.variantOrder)
		local defaultVariants = options.defaultVariants or {}
		local compoundVariants = options.compoundVariants or {}

		local selectedVariants: { [string]: string | boolean | number } = merge(defaultVariants)

		for _, variantName in ipairs(variantOrder) do
			if overrides[variantName] ~= nil then
				selectedVariants[variantName] = overrides[variantName]
			end
		end

		local resolvedProps: Types.Props = merge(baseProps)

		for _, variantName in ipairs(variantOrder) do
			local variantOptions = variants[variantName]
			local selectedValue = selectedVariants[variantName]
			local variantProps = variantOptions[tostring(selectedValue)]

			if variantProps then
				resolvedProps = merge(resolvedProps, variantProps)
			end
		end

		for _, compound in ipairs(compoundVariants) do
			if matchesCompound(compound, selectedVariants) then
				resolvedProps = merge(resolvedProps, compound.props)
			end
		end

		local cleanProps: Types.Props = merge(overrides)

		for _, variantName in ipairs(variantOrder) do
			cleanProps[variantName] = nil
		end

		return merge(resolvedProps, cleanProps)
	end
end

return cva
