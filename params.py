import json
from dataclasses import dataclass
from itertools import chain
from typing import List, Tuple

# ---------------------------------------------------------------------
# Field (KoalaBear)
# ---------------------------------------------------------------------

P = 2**31 - 2**24 + 1

class Fp:
    __slots__ = ("value",)
    def __init__(self, value: int):
        self.value = value % P
    def __add__(self, other: "Fp") -> "Fp":
        return Fp(self.value + other.value)
    def __mul__(self, other: "Fp") -> "Fp":
        return Fp(self.value * other.value)
    def __pow__(self, exponent: int) -> "Fp":
        return Fp(pow(self.value, exponent, P))
    def __truediv__(self, other: "Fp") -> "Fp":
        # modular inverse via pow(-1, P)
        return Fp(self.value * pow(other.value, -1, P))
    def __int__(self) -> int:
        return self.value

@dataclass(frozen=True)
class Poseidon2Params:
    width: int       
    rounds_f: int    
    rounds_p: int    
    internal_diag_vectors: List[Fp] 

def generate_spec_round_constants(params: Poseidon2Params) -> List[Fp]:
    total = params.rounds_f * params.width + params.rounds_p
    return [Fp(i) for i in range(total)]

M4_MATRIX = [
    [Fp(2), Fp(3), Fp(1), Fp(1)],
    [Fp(1), Fp(2), Fp(3), Fp(1)],
    [Fp(1), Fp(1), Fp(2), Fp(3)],
    [Fp(3), Fp(1), Fp(1), Fp(2)],
]

def apply_m4(chunk: List[Fp]) -> List[Fp]:
    res = [Fp(0)] * 4
    for i in range(4):
        acc = Fp(0)
        for j in range(4):
            acc = acc + (M4_MATRIX[i][j] * chunk[j])
        res[i] = acc
    return res

def external_linear_layer(state: List[Fp], width: int) -> List[Fp]:
    assert width % 4 == 0 and width >= 8
    after_m4 = list(
        chain.from_iterable(
            apply_m4(state[i:i+4]) for i in range(0, width, 4)
        )
    )
    sums = [
        sum((after_m4[j + k] for j in range(0, width, 4)), Fp(0))
        for k in range(4)
    ]
    return [s + sums[i & 3] for i, s in enumerate(after_m4)]

def external_diagonal(width: int) -> List[Fp]:
    # probe with basis vectors to get diagonal of M_E
    diag: List[Fp] = []
    for i in range(width):
        basis = [Fp(0) for _ in range(width)]
        basis[i] = Fp(1)
        out = external_linear_layer(basis, width)
        diag.append(out[i])
    return diag

PARAMS_16 = Poseidon2Params(
    width=16, rounds_f=8, rounds_p=20,
    internal_diag_vectors=[
        Fp(-2), Fp(1), Fp(2), Fp(1)/Fp(2),
        Fp(3), Fp(4), Fp(-1)/Fp(2), Fp(-3),
        Fp(-4), Fp(1)/Fp(2**8), Fp(1)/Fp(8), Fp(1)/Fp(2**24),
        Fp(-1)/Fp(2**8), Fp(-1)/Fp(8), Fp(-1)/Fp(16), Fp(-1)/Fp(2**24),
    ],
)

PARAMS_24 = Poseidon2Params(
    width=24, rounds_f=8, rounds_p=23,
    internal_diag_vectors=[
        Fp(-2), Fp(1), Fp(2), Fp(1)/Fp(2),
        Fp(3), Fp(4), Fp(-1)/Fp(2), Fp(-3),
        Fp(-4), Fp(1)/Fp(2**8), Fp(1)/Fp(4), Fp(1)/Fp(8),
        Fp(1)/Fp(16), Fp(1)/Fp(32), Fp(1)/Fp(64), Fp(1)/Fp(2**24),
        Fp(-1)/Fp(2**8), Fp(-1)/Fp(8), Fp(-1)/Fp(16), Fp(-1)/Fp(32),
        Fp(-1)/Fp(64), Fp(-1)/Fp(2**7), Fp(-1)/Fp(2**9), Fp(-1)/Fp(2**24),
    ],
)

def split_rcs(params: Poseidon2Params, flat: List[int]) -> Tuple[List[List[int]], List[int]]:
    rf, rp, w = params.rounds_f, params.rounds_p, params.width
    ext = [flat[i*w:(i+1)*w] for i in range(rf)]  # [R_F][WIDTH]
    intr = flat[rf*w : rf*w + rp]                 # [R_P]
    return ext, intr

def wrap_lines(nums: List[int], per_line: int = 8, indent: str = "    ") -> str:
    lines = []
    for i in range(0, len(nums), per_line):
        lines.append(indent + ", ".join(str(x) for x in nums[i:i+per_line]) + ",")
    return "\n".join(lines)

def zig_array_1d(name: str, arr: List[int], decl_len: int) -> str:
    body = wrap_lines(arr)
    return f"const {name} = [{decl_len}]u32{{\n{body}\n}};"

def zig_array_2d(name: str, rows: List[List[int]], rows_len: int, cols_len: int) -> str:
    inner = []
    for row in rows:
        inner.append("    { " + ", ".join(str(x) for x in row) + " },")
    body = "\n".join(inner)
    return f"const {name} = [{rows_len}][{cols_len}]u32{{\n{body}\n}};"

def make_zig_bundle(prefix: str, params: Poseidon2Params,
                    external_rcs: List[List[int]],
                    internal_rcs: List[int],
                    internal_diag: List[int],
                    external_diag: List[int]) -> dict:
    return {
        # For direct pasting into a Zig file:
        "WIDTH":             f"const {prefix}_WIDTH: u32 = {params.width};",
        "EXTERNAL_RCS":      zig_array_2d(f"{prefix}_EXTERNAL_RCS", external_rcs, params.rounds_f, params.width),
        "INTERNAL_RCS":      zig_array_1d(f"{prefix}_INTERNAL_RCS", internal_rcs, params.rounds_p),
        "INTERNAL_DIAG":     zig_array_1d(f"{prefix}_INTERNAL_DIAG", internal_diag, params.width),
        "EXTERNAL_DIAG":     zig_array_1d(f"{prefix}_EXTERNAL_DIAG", external_diag, params.width),
        "MODULUS":           f"const {prefix}_MODULUS: u32 = {P};",
    }

def main() -> None:
    # WIDTH 16
    rc16_flat = [int(x) for x in generate_spec_round_constants(PARAMS_16)]
    ext16, intr16 = split_rcs(PARAMS_16, rc16_flat)
    id16 = [int(x) for x in PARAMS_16.internal_diag_vectors]
    ed16 = [int(x) for x in external_diagonal(PARAMS_16.width)]

    # WIDTH 24
    rc24_flat = [int(x) for x in generate_spec_round_constants(PARAMS_24)]
    ext24, intr24 = split_rcs(PARAMS_24, rc24_flat)
    id24 = [int(x) for x in PARAMS_24.internal_diag_vectors]
    ed24 = [int(x) for x in external_diagonal(PARAMS_24.width)]

    # Package everything
    data = {
        "modulus": P,
        "width16": {
            # "arrays": {
            #     "external_rcs": ext16,
            #     "internal_rcs": intr16,
            #     "internal_diag": id16,
            #     "external_diag": ed16,
            # },
            "zig": make_zig_bundle("W16", PARAMS_16, ext16, intr16, id16, ed16),
            "for_poseidon2_signature": {
                "internal_diagonal_param": "W16_INTERNAL_DIAG",
                "external_rcs_param":     "W16_EXTERNAL_RCS",
                "internal_rcs_param":     "W16_INTERNAL_RCS"
            }
        },
        "width24": {
            # "arrays": {
            #     "external_rcs": ext24,
            #     "internal_rcs": intr24,
            #     "internal_diag": id24,
            #     "external_diag": ed24,
            # },
            "zig": make_zig_bundle("W24", PARAMS_24, ext24, intr24, id24, ed24),
            "for_poseidon2_signature": {
                "internal_diagonal_param": "W24_INTERNAL_DIAG",
                "external_rcs_param":     "W24_EXTERNAL_RCS",
                "internal_rcs_param":     "W24_INTERNAL_RCS"
            }
        },
        "note": "Round constants here are deterministic test values (0..N-1). Replace with domain-separated, pseudorandom constants for production."
    }

    with open("poseidon2_koalabear_constants.json", "w") as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    main()
