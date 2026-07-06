import math
import unittest

from src.low_pass_filter import (
    RCFilterConfig,
    alpha,
    apply_low_pass_filter,
    cutoff_frequency,
    generate_mixed_signal,
)


class LowPassFilterTest(unittest.TestCase):
    def test_cutoff_frequency_matches_rc_formula(self):
        config = RCFilterConfig(resistance_ohm=1_000.0, capacitance_farad=1e-6)

        result = cutoff_frequency(config)

        self.assertAlmostEqual(result, 1.0 / (2.0 * math.pi * 0.001), places=6)

    def test_alpha_is_between_zero_and_one(self):
        config = RCFilterConfig()

        result = alpha(config)

        self.assertGreater(result, 0.0)
        self.assertLess(result, 1.0)

    def test_filter_converges_for_constant_input(self):
        config = RCFilterConfig()
        samples = [1.0] * 200

        result = apply_low_pass_filter(samples, config)

        self.assertAlmostEqual(result[-1], 1.0, places=4)

    def test_filter_smooths_mixed_signal(self):
        config = RCFilterConfig(duration_seconds=0.02)
        samples = generate_mixed_signal(config)

        result = apply_low_pass_filter(samples, config)

        input_delta = sum(abs(samples[i] - samples[i - 1]) for i in range(1, len(samples)))
        output_delta = sum(abs(result[i] - result[i - 1]) for i in range(1, len(result)))
        self.assertLess(output_delta, input_delta)

    def test_invalid_config_raises_error(self):
        config = RCFilterConfig(resistance_ohm=0)

        with self.assertRaises(ValueError):
            cutoff_frequency(config)


if __name__ == "__main__":
    unittest.main()

