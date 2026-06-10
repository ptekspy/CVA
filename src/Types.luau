--!strict

--[=[
	Core prop definition: a flat table of Roblox GUI properties or React event handlers.
	Keys are property names (e.g., "BackgroundColor3", "TextSize") or event keys.
	Values are property values or functions (for event handlers).
]=]
export type Props = { [string]: any }

--[=[
	A single variant option: the props to apply when this variant is selected.
	Example:
	  primary = { BackgroundColor3 = Color3.fromRGB(255, 170, 0), TextColor3 = ... }
]=]
export type VariantOption = Props

--[=[
	A group of named options for a single variant dimension.
	Example:
	  {
	    primary = { ... props ... },
	    secondary = { ... props ... },
	  }
]=]
export type VariantGroup = {
	[string]: VariantOption,
}

--[=[
	All defined variant dimensions and their options.
	Maps variant name → { option name → option props }
	Example:
	  {
	    intent = { primary = {...}, secondary = {...} },
	    size = { sm = {...}, lg = {...} },
	  }
]=]
export type VariantMap = {
	[string]: VariantGroup,
}

--[=[
	A compound variant: applies props when multiple variant conditions match.
	- `props`: the props to merge when this compound variant matches
	- [variantName]: string | boolean | number the expected value for that variant
	
	Example:
	  {
	    intent = "primary",
	    size = "lg",
	    props = { TextSize = 30 },
	  }
	
	Matches when `intent="primary"` AND `size="lg"`.
]=]
export type CompoundVariant = {
	props: VariantOption,
	[string]: string | boolean | number | nil,
}

--[=[
	Configuration for creating a CVA factory.
	- `variants`: Named variant dimensions with their options
	- `defaultVariants`: Default values for each variant when not specified
	- `compoundVariants`: Conditional variant combinations
]=]
export type CvaOptions = {
	variants: VariantMap?,
	defaultVariants: { [string]: string | boolean | number }?,
	compoundVariants: { CompoundVariant }?,
}

--[=[
	The CVA factory function signature.
	Returns a function that takes variant + override props and merges them into final props.
	
	The returned function's behavior:
	1. Applies base props
	2. Applies selected variant props (using defaults + passed-in selections)
	3. Applies matching compound variant props
	4. Applies any passed-in prop overrides (last wins)
	
	Example usage:
	  local button = cva({ BorderSizePixel = 0 }, {
	    variants = { intent = { primary = {...} } },
	    defaultVariants = { intent = "primary" },
	  })
	  local props = button({ intent = "primary", Text = "Click" })
]=]
export type CvaFunction = (overrides: Props?) -> Props

--[=[
	The main CVA factory function.
	Signature: (baseProps: Props, options: CvaOptions?) -> CvaFunction
]=]
export type Cva = (baseProps: Props, options: CvaOptions?) -> CvaFunction
