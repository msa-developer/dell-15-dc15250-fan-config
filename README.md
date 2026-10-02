# Dell 15 DC15250 — fan control config

Restores the fan curve for this laptop. Only needed if the BIOS fan control
misbehaves, otherwise the firmware handles the fan fine on its own.

## Install

```bash
yay -S i8kutils dell-bios-fan-control-git
```

## Apply

```bash
sudo cp /etc/i8kutils/i8kmon.conf /etc/i8kutils/i8kmon.conf.bak
sudo cp ~/dell-15-dc15250-fan-config/i8kmon.conf /etc/i8kutils/i8kmon.conf
sudo systemctl restart i8kmon
```

`dell-bios-fan-control` must stay **enabled** — it hands fan control from the
BIOS to i8kmon. i8kmon has nothing to control otherwise.

## Verify

```bash
i8kctl
watch -n2 'echo "cpu=$(( $(cat /sys/class/hwmon/hwmon3/temp1_input)/1000 ))C rpm=$(cat /sys/class/hwmon/hwmon3/fan1_input)"'
```

Expect ~3600 RPM below 45C and 5800 RPM above it.

To see i8kmon's state decisions, set `set config(verbose) 1` in the config,
restart, then:

```bash
journalctl -u i8kmon -b -f | grep -iE "switched|temperature"
```

`fan 2 not found` in the log is expected on a single-fan laptop.

## Revert

```bash
sudo cp /etc/i8kutils/i8kmon.conf.bak /etc/i8kutils/i8kmon.conf
sudo systemctl restart i8kmon
```

## Hand the fan back to the BIOS

```bash
sudo dell-bios-fan-control 1
sudo systemctl disable --now i8kmon
```

## Notes

- The curve is tuned for low noise being irrelevant. On battery it will be loud.
- Firefox under heavy load generates more heat than the fan can remove. Closing
  it is the only real fix for high temps under load.
- Run `sudo systemctl disable --now thermald` if thermald is installed. It also
  writes to the fan PWM register and will fight i8kmon for control.
