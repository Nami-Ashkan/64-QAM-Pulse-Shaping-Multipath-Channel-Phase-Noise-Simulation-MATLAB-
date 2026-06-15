# 64-QAM-Pulse-Shaping-Multipath-Channel-Phase-Noise-Simulation-MATLAB-
This repository contains MATLAB simulations of a complete digital communication system, including 64-QAM modulation, root-raised cosine pulse shaping, multipath fading channel modeling, additive white Gaussian noise (AWGN), receiver filtering, symbol detection, and oscillator phase noise effects.
# Digital Communication System Simulation (MATLAB)

## Overview
This project simulates a full digital communication chain using MATLAB. It models 64-QAM transmission, pulse shaping, multipath channel distortion, noise effects, and phase noise. The system demonstrates how real-world wireless impairments affect signal quality in both time and frequency domains.

---

## System Features

- 64-QAM symbol generation
- Root Raised Cosine (RRC) pulse shaping
- Oversampling and symbol-rate transmission
- Power spectral density (FFT-based spectrum analysis)
- Multipath channel modeling (FIR channel response)
- AWGN noise addition with SNR control
- Receiver matched filtering
- Symbol-rate sampling and constellation analysis
- Oscillator phase noise simulation

---

## System Architecture

### 1. Transmitter
- Random symbol generation
- 64-QAM constellation mapping
- Upsampling by factor `r`
- RRC transmit filter

### 2. Channel
- Multipath FIR channel:
  - Example models: `b1`, `b2`, `b3`
- AWGN noise with configurable SNR
- Optional phase noise model

### 3. Receiver
- Matched RRC filtering
- Symbol synchronization (ideal sampling)
- Constellation recovery

---

## Key Parameters

| Parameter | Description |
|----------|-------------|
| R | Symbol rate (10 MHz) |
| M | Modulation order (64-QAM) |
| r | Oversampling factor |
| alpha | RRC roll-off factor (0.2) |
| N_symbols | Number of transmitted symbols |
| SNRdB | Signal-to-noise ratio |
| Beta | Phase noise bandwidth |

---

## Files

### Main Simulation Script
- Full system simulation including TX → Channel → RX
- Spectrum analysis (TX/RX comparison)
- Constellation plots
- Noise and phase impairment modeling

### `phasenoise.m`
Generates oscillator phase noise using a Wiener process model:

- Inputs:
  - `N`: number of samples
  - `Fs`: sampling frequency
  - `Beta`: phase noise bandwidth
- Output:
  - Complex exponential phase noise signal

---

## How to Run

1. Open MATLAB
2. Run the main script directly
3. Ensure `phasenoise.m` is in the same directory
4. Observe generated figures:
   - TX/RX spectrum
   - Channel effects
   - Constellation distortion

---

## Outputs

- 64-QAM constellation diagram (clean vs noisy)
- Frequency spectrum before/after channel
- Multipath channel response
- Phase-noise-affected constellation
- Symbol distortion visualization

---

## Key Concepts Demonstrated

- Digital modulation (M-QAM)
- Nyquist pulse shaping
- Wireless multipath fading
- AWGN channel modeling
- SNR scaling in oversampled systems
- Matched filtering
- Phase noise in RF oscillators

---

## Applications

- Wireless communications simulation
- RF system design education
- Digital modulation analysis
- SDR (Software Defined Radio) modeling
- Academic communication theory labs

---

## Notes

- System assumes ideal timing synchronization
- Channel model is deterministic FIR multipath
- Phase noise is modeled as Wiener phase process
- All signals are complex baseband

---

## Author
Ashkan

