# CVA

**C**lass **V**ariance **A**uthority for Roblox React.

A powerful utility library for composing Roblox GUI element properties (props) with type-safe variants, default variants, and compound variants. CVA helps you build reusable, maintainable component style systems that scale across your project.

Inspired by [class-variance-authority](https://cva.style/), but adapted for React Lua component development in Roblox.

## Features

- **Type-safe variants** — Define component styles with named variants and variant options
- **Default variants** — Set sensible defaults that can be overridden
- **Compound variants** — Combine multiple variant conditions to apply specific props
- **Props merging** — Intelligent merging ensures base props, variants, compounds, and overrides are applied in the correct order
- **Clean API** — Simple, declarative API inspired by industry-standard CVA
- **React Lua integration** — Works seamlessly with React Lua components

## Installation

```bash
wally add ptekspy/cva
```

## Usage

### Basic Example

Define button styles with intent (primary/secondary) and size (sm/md/lg) variants:

```lua
local React = require(game:GetService("ReplicatedStorage").Packages.React)
local cva = require(game:GetService("ReplicatedStorage").Packages.CVA)

local buttonStyles = cva({
	Size = UDim2.fromOffset(180, 44),
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
}, {
	variants = {
		intent = {
			primary = {
				BackgroundColor3 = Color3.fromRGB(255, 170, 0),
				TextColor3 = Color3.fromRGB(20, 20, 20),
			},
			secondary = {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				TextColor3 = Color3.fromRGB(255, 255, 255),
			},
		},
		size = {
			sm = {
				Size = UDim2.fromOffset(120, 36),
				TextSize = 16,
			},
			md = {
				Size = UDim2.fromOffset(180, 44),
				TextSize = 20,
			},
			lg = {
				Size = UDim2.fromOffset(240, 56),
				TextSize = 26,
			},
		},
	},
	defaultVariants = {
		intent = "primary",
		size = "md",
	},
})
```

### Using in a React Component

Use the returned function in your component to merge variant styles with component props:

```lua
local function Button(props)
	return React.createElement("TextButton", buttonStyles({
		intent = props.intent,
		size = props.size,
		Text = props.Text,
		[React.Event.Activated] = props.onActivated,
	}))
end

-- Usage
React.createElement(Button, {
	intent = "primary",
	size = "lg",
	Text = "Click Me",
	onActivated = function()
		print("Button clicked!")
	end,
})
```

### Overriding Default Variants

You can override default variants on a per-call basis:

```lua
-- Uses default variants: intent="primary", size="md"
local primaryButton = buttonStyles({ Text = "Save" })

-- Override the intent variant
local secondaryButton = buttonStyles({
	intent = "secondary",
	Text = "Cancel",
})

-- Override both variants
local smallPrimaryButton = buttonStyles({
	size = "sm",
	Text = "Delete",
})
```

### Direct Prop Overrides

You can always override any prop directly, even those set by variants:

```lua
buttonStyles({
	intent = "primary",
	Text = "Click Me",
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), -- Overrides intent's color
	TextSize = 14, -- Overrides size's TextSize
})
```

### Compound Variants

Compound variants let you apply specific props when a combination of variants matches. This is useful for special styling when certain variant combinations occur:

```lua
local buttonStyles = cva(
	{ BorderSizePixel = 0 },
	{
		variants = {
			intent = {
				primary = { BackgroundColor3 = Color3.fromRGB(255, 170, 0) },
				danger = { BackgroundColor3 = Color3.fromRGB(220, 60, 60) },
			},
			size = {
				sm = { Size = UDim2.fromOffset(120, 36) },
				lg = { Size = UDim2.fromOffset(240, 56) },
			},
		},
		defaultVariants = {
			intent = "primary",
			size = "sm",
		},
		compoundVariants = {
			{
				intent = "primary",
				size = "lg",
				props = {
					TextSize = 30,
					BackgroundColor3 = Color3.fromRGB(255, 200, 0), -- Brighter gold for large primary
				},
			},
			{
				intent = "danger",
				size = "lg",
				props = {
					TextSize = 28,
					BackgroundColor3 = Color3.fromRGB(255, 80, 80), -- Brighter red for large danger
				},
			},
		},
	}
)

-- When intent="primary" AND size="lg", the compound variant props are applied
local largeButton = buttonStyles({ intent = "primary", size = "lg" })
```

Compound variants are applied after regular variants but before direct prop overrides, allowing for fine-grained control over complex styling rules.

## API Reference

### `cva(baseProps, options?): CvaFunction`

Creates and returns a function that merges base props with variant and compound variant props based on the options provided.

#### Parameters

**`baseProps: Props`**

A table of base properties that are applied to every call. These form the foundation of your component styling.

```lua
local baseProps = {
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
}
```

**`options: CvaOptions?` (optional)**

Configuration object for defining variants and compound variants.

##### `options.variants: VariantMap?`

A table mapping variant names to tables of variant options and their props. Each variant option becomes a choice that consumers of the CVA can select.

```lua
variants = {
	-- Variant name
	intent = {
		-- Variant option
		primary = { BackgroundColor3 = Color3.fromRGB(255, 170, 0) },
		secondary = { BackgroundColor3 = Color3.fromRGB(40, 40, 40) },
	},
	size = {
		sm = { Size = UDim2.fromOffset(120, 36), TextSize = 16 },
		md = { Size = UDim2.fromOffset(180, 44), TextSize = 20 },
		lg = { Size = UDim2.fromOffset(240, 56), TextSize = 26 },
	},
}
```

##### `options.defaultVariants: { [string]: string | number | boolean }?`

Default variant selections that are used when a variant is not explicitly provided.

```lua
defaultVariants = {
	intent = "primary",
	size = "md",
}
```

##### `options.compoundVariants: { CompoundVariant }?`

A table of compound variant definitions. Each compound variant applies additional props when all of its variant conditions match.

```lua
compoundVariants = {
	{
		intent = "primary",
		size = "lg",
		props = { TextSize = 30 },
	},
	{
		intent = "danger",
		size = "lg",
		props = { TextSize = 28 },
	},
}
```

#### Returns

A function with the signature `function(overrides: Props?): Props` that returns a merged props table.

### Props Merging Order

When you call the returned function with props, they are merged in this order:

1. **Base props** are applied first (lowest priority)
2. **Default variants** are applied second
3. **Selected variants** override default variants (based on what you pass in)
4. **Matching compound variants** are applied (can override both)
5. **Directly passed props** are merged last (highest priority)

This ensures maximum control while maintaining a predictable resolution order:

```lua
buttonStyles({
	intent = "primary",
	size = "lg",
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), -- This wins
})
-- Final color: RGB(0, 0, 0) from direct override
-- (not from intent variant or compound variant)
```

## Type Definitions

CVA exports several types for use in Luau:

```lua
export type Props = { [any]: any }

export type VariantOption = { [any]: any }

export type VariantGroup = { [string]: VariantOption }

export type VariantMap = { [string]: VariantGroup }

export type CompoundVariant = {
	[string]: string | number | boolean,
	props: Props,
}

export type CvaOptions = {
	variants: VariantMap?,
	defaultVariants: { [string]: string | number | boolean }?,
	compoundVariants: { CompoundVariant }?,
}

export type CvaFunction = (overrides: Props?) -> Props

export type Cva = (baseProps: Props, options: CvaOptions?) -> CvaFunction
```

## Best Practices

### Naming Conventions

Use clear, semantic names for variants:

```lua
-- Good
variants = {
	intent = { primary = {...}, secondary = {...}, danger = {...} },
	size = { sm = {...}, md = {...}, lg = {...} },
}

-- Less clear
variants = {
	theme = { a = {...}, b = {...}, c = {...} },
	dim = { x = {...}, y = {...}, z = {...} },
}
```

### Organizing Complex Components

For components with many variants, consider grouping related options:

```lua
local buttonStyles = cva(baseProps, {
	variants = {
		-- Visual intent
		intent = {
			primary = {...},
			secondary = {...},
			danger = {...},
			success = {...},
		},
		-- Size
		size = {
			xs = {...},
			sm = {...},
			md = {...},
			lg = {...},
			xl = {...},
		},
		-- State
		disabled = {
			["true"] = { Transparency = 0.5, Active = false },
			["false"] = { Transparency = 0, Active = true },
		},
	},
})
```

### Using Compound Variants for Complex Rules

Use compound variants instead of deeply nested logic:

```lua
-- Good: Explicit compound rules
compoundVariants = {
	{ size = "lg", intent = "primary", props = { TextSize = 30 } },
	{ size = "lg", intent = "danger", props = { TextSize = 28 } },
}

-- Less maintainable: Logic inside components
if props.size == "lg" and props.intent == "primary" then
	props.TextSize = 30
end
```

## Troubleshooting

### Props Not Applying

If a prop isn't appearing in the output, check the resolution order. Direct props always win, so:

```lua
-- The BackgroundColor3 from intent will be overridden by the direct prop
buttonStyles({
	intent = "primary",
	BackgroundColor3 = Color3.fromRGB(100, 100, 100),
})
```

### Variant Not Recognized

Make sure the variant value matches exactly (case-sensitive). Typos will be silently ignored:

```lua
local buttonStyles = cva(baseProps, {
	variants = {
		size = {
			sm = {...},
			md = {...},
			lg = {...},
		},
	},
})

-- This works
buttonStyles({ size = "lg" })

-- This is silently ignored (typo: "LG")
buttonStyles({ size = "LG" }) -- Uses default instead
```

### Compound Variants Not Applying

Ensure all variant conditions in the compound match exactly. A compound only applies if ALL its conditions are met:

```lua
compoundVariants = {
	{
		intent = "primary",
		size = "lg",
		props = { TextSize = 30 },
	},
}

-- Applies compound
buttonStyles({ intent = "primary", size = "lg" })

-- Does NOT apply compound (missing size condition)
buttonStyles({ intent = "primary" })

-- Does NOT apply compound (only one condition matches)
buttonStyles({ intent = "primary", size = "md" })
```

## Examples

### Label/Badge Component

```lua
local badgeStyles = cva(
	{ Font = Enum.Font.GothamBold, TextScaled = true },
	{
		variants = {
			variant = {
				default = { BackgroundColor3 = Color3.fromRGB(200, 200, 200) },
				success = { BackgroundColor3 = Color3.fromRGB(34, 197, 94) },
				warning = { BackgroundColor3 = Color3.fromRGB(251, 146, 60) },
				error = { BackgroundColor3 = Color3.fromRGB(239, 68, 68) },
			},
		},
		defaultVariants = {
			variant = "default",
		},
	}
)
```

### Input Field Component

```lua
local inputStyles = cva(
	{
		BorderSizePixel = 1,
		BorderColor3 = Color3.fromRGB(200, 200, 200),
		Font = Enum.Font.Gotham,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	},
	{
		variants = {
			state = {
				default = { BorderColor3 = Color3.fromRGB(200, 200, 200) },
				focused = { BorderColor3 = Color3.fromRGB(59, 130, 246) },
				error = { BorderColor3 = Color3.fromRGB(239, 68, 68) },
			},
			size = {
				sm = { TextSize = 12 },
				md = { TextSize = 14 },
				lg = { TextSize = 16 },
			},
		},
		defaultVariants = {
			state = "default",
			size = "md",
		},
	}
)
```

## Resources

- **Original CVA** — [cva.style](https://cva.style/)
- **React Lua** — [jsdotlua/react-lua](https://github.com/jsdotlua/react-lua)
- **Roblox** — [roblox.com](https://www.roblox.com)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to improve CVA.

## License

Apache-2.0
