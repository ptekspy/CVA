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

local function cva(baseProps: Types.Props, options: Types.CvaOptions?): Types.CvaFunction
	options = options or {}

	return function(overrides: Types.Props?): Types.Props
		overrides = overrides or {}

		local variants = options.variants or {}
		local defaultVariants = options.defaultVariants or {}
		local compoundVariants = options.compoundVariants or {}

		local selectedVariants: { [string]: string | boolean | number } = merge(defaultVariants)

		for variantName, _ in pairs(variants) do
			if overrides[variantName] ~= nil then
				selectedVariants[variantName] = overrides[variantName]
			end
		end

		local resolvedProps: Types.Props = merge(baseProps)

		for variantName, variantOptions in pairs(variants) do
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

		for variantName, _ in pairs(variants) do
			cleanProps[variantName] = nil
		end

		return merge(resolvedProps, cleanProps)
	end
end

return cva
