"""RC low pass filter simulation.

This module models a first-order RC low pass filter and exports simulation
results to CSV so the behavior can be reviewed from GitHub or a spreadsheet.
"""

from __future__ import annotations

import argparse
import csv
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence


@dataclass(frozen=True)
class RCFilterConfig:
    """Configuration for a first-order RC low pass filter."""

    resistance_ohm: float = 1_000.0
    capacitance_farad: float = 1e-6
    sample_rate_hz: float = 10_000.0
    duration_seconds: float = 0.05
    signal_frequency_hz: float = 50.0
    noise_frequency_hz: float = 1_000.0
    noise_amplitude: float = 0.35

    def validate(self) -> None:
        values = {
            "resistance_ohm": self.resistance_ohm,
            "capacitance_farad": self.capacitance_farad,
            "sample_rate_hz": self.sample_rate_hz,
            "duration_seconds": self.duration_seconds,
            "signal_frequency_hz": self.signal_frequency_hz,
            "noise_frequency_hz": self.noise_frequency_hz,
        }
        for name, value in values.items():
            if value <= 0:
                raise ValueError(f"{name} must be greater than zero")
        if self.noise_amplitude < 0:
            raise ValueError("noise_amplitude must be zero or positive")

    @property
    def time_constant(self) -> float:
        return self.resistance_ohm * self.capacitance_farad

    @property
    def sample_interval(self) -> float:
        return 1.0 / self.sample_rate_hz


def cutoff_frequency(config: RCFilterConfig) -> float:
    """Return the -3 dB cutoff frequency of an RC low pass filter."""

    config.validate()
    return 1.0 / (2.0 * math.pi * config.time_constant)


def alpha(config: RCFilterConfig) -> float:
    """Return the discrete-time smoothing coefficient."""

    config.validate()
    dt = config.sample_interval
    return dt / (config.time_constant + dt)


def generate_time_axis(config: RCFilterConfig) -> list[float]:
    """Generate evenly spaced time samples for the configured duration."""

    config.validate()
    sample_count = int(config.sample_rate_hz * config.duration_seconds)
    return [index * config.sample_interval for index in range(sample_count)]


def generate_mixed_signal(config: RCFilterConfig) -> list[float]:
    """Generate a low-frequency sine wave mixed with high-frequency noise."""

    times = generate_time_axis(config)
    samples: list[float] = []
    for time_value in times:
        signal = math.sin(2.0 * math.pi * config.signal_frequency_hz * time_value)
        noise = config.noise_amplitude * math.sin(
            2.0 * math.pi * config.noise_frequency_hz * time_value
        )
        samples.append(signal + noise)
    return samples


def apply_low_pass_filter(samples: Sequence[float], config: RCFilterConfig) -> list[float]:
    """Apply a first-order low pass filter to input samples."""

    if not samples:
        return []

    smoothing = alpha(config)
    output = [samples[0]]
    previous = samples[0]

    for sample in samples[1:]:
        previous = previous + smoothing * (sample - previous)
        output.append(previous)

    return output


def write_csv(
    path: Path,
    times: Iterable[float],
    inputs: Iterable[float],
    outputs: Iterable[float],
) -> None:
    """Write simulation data to CSV."""

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["time", "input", "output"])
        for row in zip(times, inputs, outputs):
            writer.writerow([f"{row[0]:.8f}", f"{row[1]:.8f}", f"{row[2]:.8f}"])


def run_simulation(config: RCFilterConfig, output_path: Path) -> tuple[float, int]:
    """Run the full simulation and save the result to CSV."""

    times = generate_time_axis(config)
    inputs = generate_mixed_signal(config)
    outputs = apply_low_pass_filter(inputs, config)
    write_csv(output_path, times, inputs, outputs)
    return cutoff_frequency(config), len(inputs)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="RC low pass filter simulation")
    parser.add_argument("--resistance", type=float, default=1_000.0)
    parser.add_argument("--capacitance", type=float, default=1e-6)
    parser.add_argument("--sample-rate", type=float, default=10_000.0)
    parser.add_argument("--duration", type=float, default=0.05)
    parser.add_argument("--signal-frequency", type=float, default=50.0)
    parser.add_argument("--noise-frequency", type=float, default=1_000.0)
    parser.add_argument("--noise-amplitude", type=float, default=0.35)
    parser.add_argument("--output", type=Path, default=Path("assets/filter_output.csv"))
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    config = RCFilterConfig(
        resistance_ohm=args.resistance,
        capacitance_farad=args.capacitance,
        sample_rate_hz=args.sample_rate,
        duration_seconds=args.duration,
        signal_frequency_hz=args.signal_frequency,
        noise_frequency_hz=args.noise_frequency,
        noise_amplitude=args.noise_amplitude,
    )
    cutoff_hz, sample_count = run_simulation(config, args.output)

    print(f"Cutoff frequency: {cutoff_hz:.2f} Hz")
    print(f"Generated samples: {sample_count}")
    print(f"Output CSV: {args.output}")


if __name__ == "__main__":
    main()

