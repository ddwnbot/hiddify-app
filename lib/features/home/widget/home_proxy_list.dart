import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:hiddify/features/proxy/widget/proxy_tile.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeProxyList extends HookConsumerWidget {
  const HomeProxyList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final showList = ref.watch(Preferences.showProxyListOnHome);
    if (!showList) return const SizedBox();

    final proxies = ref.watch(proxiesOverviewNotifierProvider);
    final sortBy = ref.watch(proxiesSortNotifierProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(t.pages.proxies.title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                PopupMenuButton<ProxiesSort>(
                  initialValue: sortBy,
                  onSelected: ref.read(proxiesSortNotifierProvider.notifier).update,
                  icon: const Icon(FluentIcons.arrow_sort_24_regular),
                  tooltip: t.pages.proxies.sort,
                  itemBuilder: (context) {
                    return [
                      ...ProxiesSort.values.map(
                        (e) => PopupMenuItem(value: e, child: Text(e.present(t))),
                      ),
                    ];
                  },
                ),
                IconButton(
                  tooltip: t.pages.proxies.testDelay,
                  onPressed: () async => await ref.read(proxiesOverviewNotifierProvider.notifier).urlTest("select"),
                  icon: const Icon(FluentIcons.flash_24_filled),
                ),
              ],
            ),
            const Gap(4),
            SizedBox(
              height: 240,
              child: proxies.when(
                data: (group) => group != null
                    ? ListView.builder(
                        itemCount: group.items.length,
                        itemExtent: 72,
                        itemBuilder: (context, index) {
                          final proxy = group.items[index];
                          return ProxyTile(
                            proxy,
                            selected: group.selected == proxy.tag,
                            onTap: () async => await ref
                                .read(proxiesOverviewNotifierProvider.notifier)
                                .changeProxy(group.tag, proxy.tag),
                          );
                        },
                      )
                    : Center(child: Text(t.pages.proxies.empty)),
                error: (error, stackTrace) => Center(child: Text(t.presentShortError(error))),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
            if (PlatformUtils.isDesktop) const Gap(4),
          ],
        ),
      ),
    );
  }
}
