# Voice Line Methods - Help Guide

## Overview

The Voice Line feature allows you to route audio between SIP and your phone's GSM radio. The system automatically detects available methods and selects the best one for optimal audio quality.

---

## Available Methods

### 1. TTY Port (★★★★★ Excellent)

**Best quality, device-specific**

Direct access to the phone modem via serial port interface.

**Requirements:**
- Device-specific serial port path
- Proper permissions (usually no root required)
- Known configuration for your device model

**Common TTY paths:**
- `/dev/ttyUSB0` - USB serial (most common)
- `/dev/ttyHS0` - Qualcomm high-speed
- `/dev/ttyGS0` - GSM serial

**How to configure:**
1. Go to Voice Line → Change Method
2. Select TTY Port (if available)
3. Tap "Manual Config" if auto-detection fails
4. Select your device's port path
5. Test the connection
6. Save settings

---

### 2. Enhanced Mode (★★★★★ Excellent)

**System-level audio access**

Provides direct digital audio path through system-level integration.

**Requirements:**
- System modifications enabled (Magisk)
- Gateway app installed as system app
- Privileged permissions granted

**Note:** This feature requires special installation. Contact support for assistance.

**Benefits:**
- Direct digital audio path
- No acoustic coupling loss
- Best audio quality
- Minimal latency (< 5ms)

---

### 3. Dongle (★★★★☆ Great)

**External hardware adapter**

Uses USB-C or TRRS hardware adapter for audio connection.

**Requirements:**
- Compatible USB-C or TRRS dongle
- Hardware connection

**Types supported:**
- USB-C with DAC (digital)
- USB-C Audio Accessory (analog)
- TRRS 3.5mm (analog)

**How to use:**
1. Connect the dongle to your device
2. System auto-detects the dongle
3. Select dongle type if needed
4. Start using

---

### 4. Telecom API (★★★☆☆ Good)

**Standard Android API**

Uses Android's standard telephony API for call control.

**Requirements:**
- None (works on all Android devices)

**Benefits:**
- Works on all Android devices
- No special permissions required
- No external hardware needed

**Limitations:**
- Medium audio quality
- Uses device audio path
- Limited control over audio routing
- May have echo issues

---

### 5. Acoustic Coupling (★★☆☆☆ Fair)

**Fallback option**

Routes audio through earphone to microphone (physical coupling).

**Requirements:**
- None (always available)

**How it works:**
- Audio plays through earphone/speaker
- Device microphone captures the audio
- Audio travels: Earphone → Air → Microphone → GSM radio

**Limitations:**
- Noticeable quality loss
- Potential echo issues
- Higher latency

---

## Troubleshooting

### TTY Port Not Available

**Problem:** TTY Port shows as unavailable

**Solutions:**
1. Try manual configuration
2. Check if your device supports TTY access
3. Try different port paths (/dev/ttyUSB0, /dev/ttyHS0, etc.)
4. Report your device model to add support

### Enhanced Mode Not Available

**Problem:** Enhanced Mode requires special setup

**Solutions:**
1. Contact support for installation assistance
2. Use Dongle or Telecom API as alternative
3. Consider rooting your device (advanced users)

### Dongle Not Detected

**Problem:** Dongle not showing as available

**Solutions:**
1. Check physical connection
2. Try different USB port
3. Ensure USB Host mode is enabled
4. Try a different dongle

### Poor Audio Quality

**Problem:** Audio quality is degraded

**Solutions:**
1. Check current method quality rating
2. Try a different method with higher quality
3. Enable echo cancellation in settings
4. Adjust volume levels

---

## Settings Reference

### Audio Settings

- **Sample Rate:** 8000/16000/48000 Hz
- **Bit Depth:** 16-bit or 24-bit
- **Channels:** Mono or Stereo

### Signal Processing

- **Right Channel Inversion:** For differential signaling (enable for 4R+1C circuits)
- **Echo Cancellation:** Reduce echo feedback
- **Noise Reduction:** Reduce background noise
- **Automatic Gain Control:** Auto-adjust volume levels

---

## FAQ

**Q: Which method should I use?**
A: Use the auto-select feature for best results. The system will choose the highest quality available method.

**Q: Can I switch methods during a call?**
A: No, method selection applies to new calls only.

**Q: Do I need root for Voice Line?**
A: Only Enhanced Mode requires root. TTY Port, Dongle, Telecom API, and Acoustic work without root.

**Q: Why is my method showing as unavailable?**
A: Tap on the method to see why it's unavailable and get suggestions.

**Q: How do I test my Voice Line configuration?**
A: Go to Voice Line → Test to run signal path and audio quality tests.

---

## Contact Support

For assistance with Voice Line setup:
- Email: support@gostsimbox.one
- Documentation: https://gostsimbox.one/docs
- Device compatibility: https://gostsimbox.one/devices
