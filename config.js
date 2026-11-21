'use strict';
'require view';
'require form';
'require fs';
'require rpc';
'require uci';
'require ui';

var callStatus = rpc.declare({
    object: 'file',
    method: 'exec',
    params: [ 'command', 'params' ],
    expect: { code: 0, stdout: '' }
});

return view.extend({
    load: function() {
        return Promise.all([
            uci.load('dns-failover')
        ]);
    },

    render: function() {
        var m, s, o;

        m = new form.Map('dns-failover', 'DNS Failover',
            'Первая версия: мониторинг и ручное переключение. Автоматический failover пока отключён.');

        s = m.section(form.TypedSection, 'main', 'Основные настройки');
        s.anonymous = true;

        o = s.option(form.Flag, 'enabled', 'Включить мониторинг');
        o.rmempty = false;

        o = s.option(form.ListValue, 'mode', 'Режим');
        o.value('monitor', 'Мониторинг (без автоматических переключений)');
        o.rmempty = false;

        o = s.option(form.Value, 'api', 'Mihomo API');
        o.rmempty = false;

        o = s.option(form.Value, 'selector', 'Имя селектора Mihomo');
        o.rmempty = false;

        o = s.option(form.Value, 'preferred', 'Основной транспорт');
        o.rmempty = false;

        o = s.option(form.Value, 'secondary', 'Резервный транспорт');
        o.rmempty = false;

        o = s.option(form.Value, 'dns_probe', 'Домен для DNS-проверки');
        o.rmempty = false;

        o = s.option(form.Value, 'interval', 'Интервал проверки (сек.)');
        o.datatype = 'uinteger';
        o.rmempty = false;

        return m.render().then(function(node) {
            var panel = E('div', { 'class': 'cbi-section' }, [
                E('h3', {}, 'Ручное переключение транспорта'),
                E('p', {}, 'Выберите транспорт для селектора DNS-Transport в Mihomo.'),
                E('button', {
                    'class': 'btn cbi-button cbi-button-action',
                    'click': ui.createHandlerFn(this, function() {
                        return callStatus('/usr/sbin/dns-failover', [ 'select', 'WARP' ])
                            .then(function(r) { ui.addNotification(null, E('p', 'WARP выбран')); })
                            .catch(function(e) { ui.addNotification(null, E('p', 'Ошибка: ' + e)); });
                    })
                }, 'Выбрать WARP'),
                ' ',
                E('button', {
                    'class': 'btn cbi-button cbi-button-action',
                    'click': ui.createHandlerFn(this, function() {
                        return callStatus('/usr/sbin/dns-failover', [ 'select', 'My-VPS' ])
                            .then(function(r) { ui.addNotification(null, E('p', 'My-VPS выбран')); })
                            .catch(function(e) { ui.addNotification(null, E('p', 'Ошибка: ' + e)); });
                    })
                }, 'Выбрать My-VPS'),
                ' ',
                E('button', {
                    'class': 'btn cbi-button',
                    'click': ui.createHandlerFn(this, function() {
                        return callStatus('/usr/sbin/dns-failover', [ 'once' ])
                            .then(function(r) { ui.addNotification(null, E('p', 'Проверка запущена; результат смотри в системном журнале.')); })
                            .catch(function(e) { ui.addNotification(null, E('p', 'Ошибка: ' + e)); });
                    })
                }, 'Проверить сейчас')
            ]);
            node.appendChild(panel);
            return node;
        }.bind(this));
    }
});
