import St from 'gi://St';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class InternetSpeedExtension extends Extension {
    enable() {
        console.log('Internet Speed Monitor: enable() called');

        this._downloadSpeed = '--';
        this._uploadSpeed = '--';

        this._label = new St.Label({
            text: '↓ --  ↑ --',
            y_align: Clutter.ActorAlign.CENTER,
            style_class: 'system-status-icon'
        });

        Main.panel._rightBox.insert_child_at_index(
            this._label,
            0
        );

        // Connect to C++ D-Bus service
        try {
            this._proxy = Gio.DBusProxy.new_for_bus_sync(
                Gio.BusType.SESSION,
                Gio.DBusProxyFlags.NONE,
                null,
                'arindamsen95.NetworkSpeed',
                '/arindamsen95/NetworkSpeed',
                'arindamsen95.NetworkSpeed',
                null
            );

            console.log('Internet Speed Monitor: D-Bus proxy created successfully');
        } catch (error) {
            console.error(`Internet Speed Monitor: Failed to create D-Bus proxy: ${error}`);
            this._proxy = null;
        }

        // Update every second
        this._timeoutId = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT,
            1,
            () => {
                this._updateSpeed();
                return GLib.SOURCE_CONTINUE;
            }
        );
    }

    /*
     * Converts MB/s (received from C++ double) into B/s, KB/s, or MB/s
     */
    _formatSpeed(speedMB) {
        if (speedMB === null || speedMB === undefined) return '--';

        const numSpeed = Number(speedMB);
        if (!Number.isFinite(numSpeed) || numSpeed < 0) return '--';

        // Convert MB/s directly to Bytes/s
        const bytesPerSec = numSpeed * 1024.0 * 1024.0;

        // 1. Less than 1 KB/s (1024 Bytes) -> Show B/s
        if (bytesPerSec < 1024.0) {
            return `${Math.round(bytesPerSec)} B/s`;
        }

        // 2. Less than 1 MB/s (1,048,576 Bytes) -> Show KB/s
        if (bytesPerSec < 1024.0 * 1024.0) {
            const kbPerSec = bytesPerSec / 1024.0;
            return `${kbPerSec.toFixed(1)} KB/s`;
        }

        // 3. 1 MB/s or higher -> Show MB/s
        return `${numSpeed.toFixed(2)} MB/s`;
    }

    _updateSpeed() {
        if (!this._proxy) {
            this._downloadSpeed = '--';
            this._uploadSpeed = '--';
            this._updateLabel();
            return;
        }

        /*
         * Fetch Download Speed
         */
        this._proxy.call(
            'GetDownload',
            null,
            Gio.DBusCallFlags.NONE,
            -1,
            null,
            (proxy, result) => {
                try {
                    const res = proxy.call_finish(result);
                    const speed = res.deepUnpack()[0];
                    this._downloadSpeed = this._formatSpeed(speed);
                } catch (error) {
                    console.error(`Internet Speed Monitor: Download D-Bus error: ${error}`);
                    this._downloadSpeed = '--';
                }
                this._updateLabel();
            }
        );

        /*
         * Fetch Upload Speed
         */
        this._proxy.call(
            'GetUpload',
            null,
            Gio.DBusCallFlags.NONE,
            -1,
            null,
            (proxy, result) => {
                try {
                    const res = proxy.call_finish(result);
                    const speed = res.deepUnpack()[0];
                    this._uploadSpeed = this._formatSpeed(speed);
                } catch (error) {
                    console.error(`Internet Speed Monitor: Upload D-Bus error: ${error}`);
                    this._uploadSpeed = '--';
                }
                this._updateLabel();
            }
        );
    }

    _updateLabel() {
        // Guard against calls occurring after disable()
        if (!this._label) return;

        this._label.text = `↓ ${this._downloadSpeed}  ↑ ${this._uploadSpeed}`;
    }

    disable() {
        console.log('Internet Speed Monitor: disable() called');

        if (this._timeoutId) {
            GLib.source_remove(this._timeoutId);
            this._timeoutId = null;
        }

        if (this._label) {
            this._label.destroy();
            this._label = null;
        }

        this._proxy = null;
        this._downloadSpeed = null;
        this._uploadSpeed = null;
    }
}
