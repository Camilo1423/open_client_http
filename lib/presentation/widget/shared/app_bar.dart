import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  // Props básicos
  final String? titleText;
  final Widget? titleWidget;

  // Props para widgets adicionales
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? flexibleSpace;

  // Props para personalización
  final Color? backgroundColor;
  final double? elevation;
  final bool centerTitle;
  final double? toolbarHeight;

  const AppBarCustom({
    super.key,
    this.titleText,
    this.titleWidget,
    this.leading,
    this.actions,
    this.flexibleSpace,
    this.backgroundColor,
    this.elevation,
    this.centerTitle = false,
    this.toolbarHeight,
  }) : assert(
         titleText != null || titleWidget != null,
         'Debes proporcionar titleText o titleWidget',
       );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Usar titleWidget si se proporciona, sino usar titleText
      title: titleWidget ?? Text(titleText ?? ''),
      leading: leading,
      actions: actions,
      flexibleSpace: flexibleSpace,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
    );
  }
}

/*
Ejemplos de uso:

1. Usando solo texto:
AppBarCustom(titleText: 'Mi Aplicación')

2. Usando un widget personalizado como título:
AppBarCustom(
  titleWidget: Row(
    children: [
      Icon(Icons.star),
      SizedBox(width: 8),
      Text('Mi App'),
    ],
  ),
)

3. Con leading personalizado:
AppBarCustom(
  titleText: 'Mi App',
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () => print('Menu pressed'),
  ),
)

4. Con actions múltiples:
AppBarCustom(
  titleText: 'Mi App',
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () => print('Search'),
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () => print('More'),
    ),
  ],
)

5. Con flexibleSpace (para efectos visuales):
AppBarCustom(
  titleText: 'Mi App',
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
      ),
    ),
  ),
)

6. Con bottom (para tabs, etc.):
AppBarCustom(
  titleText: 'Mi App',
  bottom: TabBar(
    tabs: [
      Tab(text: 'Tab 1'),
      Tab(text: 'Tab 2'),
    ],
  ),
)

7. Ejemplo completo:
AppBarCustom(
  titleWidget: Column(
    children: [
      Text('Título Principal'),
      Text('Subtítulo', style: TextStyle(fontSize: 12)),
    ],
  ),
  leading: Builder(
    builder: (context) => IconButton(
      icon: Icon(Icons.menu),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ),
  actions: [
    IconButton(
      icon: Badge(
        label: Text('3'),
        child: Icon(Icons.notifications),
      ),
      onPressed: () => print('Notifications'),
    ),
    PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(child: Text('Opción 1')),
        PopupMenuItem(child: Text('Opción 2')),
      ],
    ),
  ],
  backgroundColor: Colors.deepPurple,
  elevation: 4,
  toolbarHeight: 80,
)
*/
