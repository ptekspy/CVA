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

### Using in a Component

```lua
local function Button(props)
	return React.createElement("TextButton", buttonStyles({
		intent = props.intent,
		size = props.size,
		Text = props.Text,
		[React.Event.Activated] = props.onActivated,
	}))
end
```

### Compound Variants

Compound variants allow you to set different props based on a combination of selected variants:

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
				},
			},
		},
	}
)
```

## API

### `cva(baseProps, options?)`

Returns a function that merges base props with selected variant props.

#### Arguments

- `baseProps: { [any]: any }` — Base props applied to all variants
- `options: CvaOptions?` — Configuration object with the following properties:
  - `variants: VariantMap?` — Map of variant names to variant values
  - `defaultVariants: { [string]: string }?` — Default variant selections
  - `compoundVariants: { CompoundVariant }?` — Conditional variant combinations

#### Returns

A function that accepts props and returns the resolved props object.

### Props Merging

When you call the returned function with props:

1. Default variants are applied first
2. Selected variants override defaults
3. Matching compound variants are applied
4. Passed-in props override everything (except variant names, which are cleaned up)

This ensures you can always override any style prop directly when needed:

```lua
buttonStyles({
	intent = "primary",
	Text = "Click Me",
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), -- Overrides intent's color
})
```

## License

Apache-2.0
