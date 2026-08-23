# Dongle Help Guide

## Overview

A dongle (adapter) connects your Android device to a phone line for the GOSTsimbox Gateway. The system automatically detects connected dongles and configures optimal audio settings.

---

## Dongle Types

### 1. USB-C with DAC (★★★★★ Excellent)

**Digital interface with external DAC chip**

- **Best audio quality**
- **External DAC chip in adapter**
- **Plug and play**

**Common DAC chips:**
- PCM2704 (Texas Instruments)
- CM108 (C-Media)
- XMOS (high-end)

**How to use:**
1. Connect USB-C dongle to device
2. System auto-detects DAC
3. Select dongle type (Differential recommended)
4. Start using

---

### 2. USB-C Audio Accessory (★★★★☆ Great)

**Analog interface using device DAC**

- **Uses device's internal DAC**
- **Analog signal on SBU pins**
- **No external power needed**

**How to use:**
1. Connect USB-C Accessory dongle
2. System detects analog mode
3. Configure audio settings
4. Select dongle type by resistance measurement

---

### 3. TRRS 3.5mm (★★★☆☆ Good)

**Analog headset jack connection**

- **Standard 3.5mm jack**
- **Works with any device with headphone jack**
- **May require USB-C to 3.5mm adapter**

**How to use:**
1. Insert TRRS jack into headphone port
2. System detects jack insertion
3. Measure resistance to detect type
4. Configure wiring standard (CTIA/OMTP)

---

## Dongle Circuit Types

### Differential (4R+1C) - Recommended

**Resistance signature:**
- GND→MIC: ~10kΩ
- L→GND: ~15kΩ
- R→GND: ~15kΩ

**Best for:** Phone line connection with differential signaling

**Circuit:** 4 resistors + 1 capacitor

---

### Mono Loopback

**Resistance signature:**
- GND→MIC: ~1.8kΩ
- L→GND: ~100kΩ

**Best for:** Simple mono audio loopback

**Circuit:** L and R mixed through resistors

---

### Stereo Loopback

**Resistance signature:**
- GND→MIC: ~1.8kΩ
- L→GND: ∞ (open)
- R→GND: ∞ (open)

**Best for:** Stereo audio without mixing

---

### Earphone-to-Mic

**Resistance signature:**
- GND→MIC: ~10kΩ
- L→GND: ∞ (open)

**Best for:** Acoustic coupling (speaker → microphone)

---

## Troubleshooting

### Dongle Not Detected

**Problem:** System shows "No dongle detected"

**Solutions:**
1. Check physical connection
2. Try different USB port
3. Ensure USB Host mode is enabled
4. Restart the app
5. Try a different dongle

### Cannot Measure Resistance

**Problem:** Resistance measurement fails

**Solutions:**
- **USB-C with DAC:** This is normal! Digital interfaces don't allow resistance measurement. Select type manually.
- **USB-C Accessory/TRRS:** Check connection, ensure proper contact

### Unknown Dongle Type

**Problem:** System can't determine dongle type

**Solutions:**
1. Select type manually from list
2. Check resistance values match expected signatures
3. Verify wiring (CTIA vs OMTP for TRRS)

### Poor Audio Quality

**Problem:** Audio quality is degraded

**Solutions:**
1. Check dongle type is correct
2. Enable right channel inversion for differential
3. Adjust output volume
4. Try a different dongle

---

## Configuration Guide

### USB-C with DAC

1. **Sample Rate:** 48000 Hz (recommended)
2. **Bit Depth:** 16-bit
3. **Dongle Type:** Differential (4R+1C)
4. **Inversion:** Enabled

### USB-C Audio Accessory

1. **Sample Rate:** 48000 Hz
2. **Bit Depth:** 16-bit
3. **Dongle Type:** Measure or select manually
4. **Inversion:** Enabled for differential
5. **Volume:** 80-90%

### TRRS 3.5mm

1. **Wiring Standard:** CTIA (most devices)
2. **Dongle Type:** Measure resistance
3. **Inversion:** Enabled for differential
4. **Audio Mode:** Earphone-to-Mic or Loopback

---

## Testing

### Loopback Test

**Purpose:** Verify TX → RX signal path

**What it does:**
- Sends test tone to dongle TX
- Routes back to RX internally
- Measures signal quality

**Expected result:** Clear tone, low latency (< 10ms)

### Tone Generator Test

**Purpose:** Verify dongle output

**What it does:**
- Generates 1kHz tone
- Sends to dongle output
- Measure with oscilloscope/multimeter

**Expected result:** ~1V RMS at 1kHz

### Echo Test

**Purpose:** Verify connection to phone line

**What it does:**
- Sends tone to line
- Waits for echo
- Measures round-trip time

**Expected result:** Echo detected, latency < 100ms

### Call Test

**Purpose:** Full end-to-end test

**What it does:**
- Makes test call
- Sends test tone
- Verifies both parties can hear

**Expected result:** Clear audio both ways

---

## FAQ

**Q: Which dongle should I buy?**
A: USB-C with DAC (PCM2704 or similar) for best quality. USB-C Audio Accessory for budget option.

**Q: Do I need root for dongle?**
A: No, dongles work without root access.

**Q: Can I use multiple dongles?**
A: Only one dongle can be active at a time.

**Q: What is right channel inversion?**
A: Inverts the right channel polarity for differential signaling. Required for 4R+1C circuits.

**Q: How do I know my dongle type?**
A: Use auto-detect (Measure button) or check the circuit diagram.

**Q: TRRS or USB-C - which is better?**
A: USB-C generally provides better quality and more reliable connection.

---

## Contact Support

For assistance with dongle setup:
- Email: support@gostsimbox.one
- Documentation: https://gostsimbox.one/docs/dongles
- Compatible dongles: https://gostsimbox.one/dongles/compatible
