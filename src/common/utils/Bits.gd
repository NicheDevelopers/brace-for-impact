extends Node

const ZERO := 0

# Converts a list of layer numbers (1-based) to a bitfield.
func from(layers: Array[int]) -> int:
	var bits := 0
	for layer in layers:
		bits |= 1 << (layer - 1)
	return bits

# Enables (turns on) specific layers in the given bitfield.
func enable(bitfield: int, layers: Array[int]) -> int:
	for layer in layers:
		bitfield |= 1 << (layer - 1)
	return bitfield

# Disables (turns off) specific layers in the given bitfield.
func disable(bitfield: int, layers: Array[int]) -> int:
	for layer in layers:
		bitfield &= ~(1 << (layer - 1))
	return bitfield
