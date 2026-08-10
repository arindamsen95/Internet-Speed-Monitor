import St from 'gi://St';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

// Define DBus Proxy Interface via Wrapper (Non-blocking)
const NetworkSpeedProxy = Gio.DBusProxy.makeProxyWrapper(`
<node>
  <interface name="arindamsen95.NetworkSpeed">
    <method name="GetDownload">
      <arg type="d" direction="out"/>
    </method>
    <method name="GetUpload">
      <arg type="d" direction="out"/>
    </method>
  </interface>
</node>
`);

export default class InternetSpeedExtension extends Extension {
    enable() {
        console.log('Internet Speed Monitor: enable() called');

        this._downloadSpeed = '--';
        this._uploadSpeed = '--';

        // Create standard PanelMenu Button container for clean integration
        this._indicator = new PanelMenu.Button(0.0, 'Internet Speed Monitor', false);

        this._label = new St.Label({
            text: '↓ --  ↑ --',
            y_align: Clutter.ActorAlign.CENTER,
            style_class: 'system-status-icon'
        });

        this._indicator.add_child(this._label);

        // Official API for panel insertion (right side)
        Main.panel.addToStatusArea(this.uuid, this._indicator, 0, 'right');

        // Connect to C++ D-Bus service asynchronously using wrapper
        try {
            this._proxy = new NetworkSpeedProxy(
                Gio.DBus.session,
                'arindamsen95.NetworkSpeed',
                '/arindamsen95/NetworkSpeed'
            );
            console.log('Internet Speed Monitor: D-Bus proxy created successfully');
        } catch (error) {
            console.error(`Internet Speed Monitor: Failed to create D-Bus proxy: ${error}`);
            this._proxy = null;
        }

        // Update loop every 1 second
        this._timeoutId = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT,
            1,
            () => {
                this._updateSpeed();
                return GLib.SOURCE_CONTINUE;
            }
        );
    }

    _formatSpeed(speedMB) {
        if (speedMB === null || speedMB === undefined) return '--';

        const numSpeed = Number(speedMB);
        if (!Number.isFinite(numSpeed) || numSpeed < 0) return '--';

        const bytesPerSec = numSpeed * 1024.0 * 1024.0;

        if (bytesPerSec < 1024.0) {
            return `${Math.round(bytesPerSec)} B/s`;
        }

        if (bytesPerSec < 1024.0 * 1024.0) {
            const kbPerSec = bytesPerSec / 1024.0;
            return `${kbPerSec.toFixed(1)} KB/s`;
        }

        return `${numSpeed.toFixed(2)} MB/s`;
    }

    _updateSpeed() {
        if (!this._proxy || !this._label) {
            this._downloadSpeed = '--';
            this._uploadSpeed = '--';
            this._updateLabel();
            return;
        }

        // Fetch Download Speed
        this._proxy.GetDownloadRemote((result, error) => {
            if (!this._label) return; // Guard against tear-down race condition

            if (error) {
                console.error(`Internet Speed Monitor: Download D-Bus error: ${error}`);
                this._downloadSpeed = '--';
            } else {
                const [speed] = result;
                this._downloadSpeed = this._formatSpeed(speed);
            }
            this._updateLabel();
        });

        // Fetch Upload Speed
        this._proxy.GetUploadRemote((result, error) => {
            if (!this._label) return; // Guard against tear-down race condition

            if (error) {
                console.error(`Internet Speed Monitor: Upload D-Bus error: ${error}`);
                this._uploadSpeed = '--';
            } else {
                const [speed] = result;
                this._uploadSpeed = this._formatSpeed(speed);
            }
            this._updateLabel();
        });
    }

    _updateLabel() {
        if (!this._label) return;
        this._label.text = `↓ ${this._downloadSpeed}  ↑ ${this._uploadSpeed}`;
    }

    disable() {
        console.log('Internet Speed Monitor: disable() called');

        if (this._timeoutId) {
            GLib.source_remove(this._timeoutId);
            this._timeoutId = null;
        }

        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
            this._label = null;
        }

        this._proxy = null;
        this._downloadSpeed = null;
        this._uploadSpeed = null;
    }
}
