import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

///消息弹窗横幅
class NotifyInAppUtils {
  static NotifyView? preNotify;

  final GlobalKey<_NotifyWidgetState> _stateKey = GlobalKey();

  void show(
    BuildContext context,
    Widget child, {
    int duration = 300,
    int keepDuration = 10,
    double topOffset = kToolbarHeight,
    bool dismissDirectly = false,
    bool disableDrag = false,
    Function()? onTap,
    bool playSound = true,
    bool vibration = true,
    bool onlyOne = false,
  }) {
    _createView(
      child,
      context,
      duration,
      keepDuration,
      topOffset,
      dismissDirectly,
      disableDrag,
      onTap,
      playSound,
      vibration,
      onlyOne,
    );
  }

  void _createView(
    Widget child,
    BuildContext context,
    int duration,
    int keepDuration,
    double topOffset,
    bool dismissDirectly,
    bool disableDrag,
    Function()? onTap,
    bool playSound,
    bool vibration,
    bool onlyOne,
  ) {
    // 防止连续调用造成弹窗堆叠
    if (onlyOne) {
      preNotify?.dismiss();
      preNotify = null;
    }

    final OverlayState overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;
    // 创建显示Widget
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => NotifyWidget(
        key: _stateKey,
        finished: () {
          preNotify?.dismiss();
        },
        duration: duration,
        keepDuration: keepDuration,
        topOffset: topOffset,
        leftOffset: 0,
        dismissDirectly: dismissDirectly,
        disableDrag: disableDrag,
        child: child,
        onTap: () {
          onTap?.call();
          preNotify?.dismiss();
        },
      ),
    );
    // 使用View统一管理
    var notifyView = NotifyView();
    notifyView.overlayEntry = overlayEntry;
    notifyView.overlayState = overlayState;
    preNotify = notifyView;
    notifyView.show();
    // 震动与声音
    vibration ? HapticFeedback.heavyImpact() : null;
    playSound
        ? FlutterRingtonePlayer().play(
            android: AndroidSounds.notification,
            ios: IosSounds.glass,
            looping: false, // Android only - API >= 28
            volume: 1, // Android only - API >= 28
            asAlarm: false, // Android only - all APIs
          )
        : null;
  }
}

class NotifyView {
  OverlayEntry? overlayEntry;
  OverlayState? overlayState;
  bool dismissed = false;

  // 显示
  show() async {
    overlayState?.insert(overlayEntry!);
    // dismiss();
  }

  // 删除
  dismiss() async {
    if (dismissed) {
      return;
    }
    dismissed = true;
    overlayEntry?.remove();
  }
}

class NotifyWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback finished;

  ///进出动画时长
  final int duration;

  ///弹窗持续时长
  final int keepDuration;

  ///距离顶部偏移
  final double topOffset;

  ///距离左侧偏移
  final double leftOffset;

  ///消失时是否不显示动画
  final bool dismissDirectly;

  ///禁止向下拖拽
  final bool disableDrag;

  ///点击通知
  final Function() onTap;

  const NotifyWidget({
    super.key,
    required this.finished,
    required this.duration,
    required this.keepDuration,
    required this.topOffset,
    required this.leftOffset,
    required this.disableDrag,
    required this.dismissDirectly,
    required this.child,
    required this.onTap,
  });

  @override
  State<NotifyWidget> createState() => _NotifyWidgetState();
}

class _NotifyWidgetState extends State<NotifyWidget>
    with TickerProviderStateMixin {
  AnimationController? _playController;
  AnimationController? _playHorizontalController;
  double _offset = -1000;
  double _leftOffset = 0;
  double begin = -1000;
  double leftbegin = 0;
  Animation<double>? _offsetAnimation;
  Animation<double>? _offsetHorizontalAnimation;
  bool _reversed = false;
  Timer? _t;
  double childHeight = 0;
  double childWidth = 0;

  GlobalKey childKey = GlobalKey();

  @override
  void dispose() {
    _playController?.dispose();
    _playHorizontalController?.dispose();
    _cancelT();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((timeStamp) {
      // 获取Widget的宽高
      final box = childKey.currentContext?.findRenderObject() as RenderBox;
      childHeight = box.size.height;
      childWidth = box.size.width;
      _offset = -1 * childHeight;
      _leftOffset = -1 * childWidth;
      begin = _offset;
      leftbegin = 0;
      _play();
      _readyDismissOverlay();
    });
  }

  void _play() {
    _playController = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );
    _offsetAnimation = Tween<double>(
      begin: begin,
      end: widget.topOffset,
    ).animate(
      CurvedAnimation(
        parent: _playController!,
        curve: Curves.easeOutBack,
      ),
    );
    _playController?.addListener(
      () {
        if (mounted) {
          setState(() {
            _offset = _offsetAnimation!.value;
          });
        }
      },
    );
    _playController?.forward();

    _playHorizontalController = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );
    _offsetHorizontalAnimation = Tween<double>(
      begin: leftbegin,
      end: widget.leftOffset,
    ).animate(
      CurvedAnimation(
        parent: _playHorizontalController!,
        curve: Curves.easeOutBack,
      ),
    );
    _playHorizontalController?.addListener(
      () {
        if (mounted) {
          setState(() {
            _leftOffset = _offsetHorizontalAnimation!.value;
          });
        }
      },
    );
    _playHorizontalController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size maxSize = MediaQuery.of(context).size;

    return Positioned(
      top: _offset,
      left: _leftOffset,
      child: GestureDetector(
        onTap: widget.onTap,
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          _cancelT();
          final double temp = _leftOffset + details.delta.dx;
          _leftOffset = temp;
          setState(() {});
        },
        onHorizontalDragEnd: (details) {
          if (_leftOffset > maxSize.width / 2 ||
              -(_leftOffset) > maxSize.width / 2) {
            _horizontalClose();
          } else {
            _resetHorizontalTarget();
            _cancelT();
            _readyDismissOverlay();
          }
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          _cancelT();
          final double temp = _offset + details.delta.dy;
          if (temp > widget.topOffset + childHeight) {
            return;
          }

          if (temp > widget.topOffset) {
            if (widget.disableDrag) return;
          }

          _offset = temp;
          setState(() {});
        },
        onVerticalDragEnd: (details) {
          if (_offset < widget.topOffset / 2) {
            _close();
          } else {
            _resetTarget();
            _cancelT();
            _readyDismissOverlay();
          }
        },
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            key: childKey,
            constraints: BoxConstraints.loose(maxSize),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _resetTarget() {
    if (_reversed) {
      _offsetAnimation = Tween<double>(
        begin: _offset,
        end: widget.topOffset,
      ).animate(
        CurvedAnimation(
          parent: _playController!,
          curve: Curves.easeOutBack,
        ),
      );
      _playController?.forward();
      _reversed = false;
    } else {
      _offsetAnimation = Tween<double>(
        begin: widget.topOffset,
        end: _offset,
      ).animate(
        CurvedAnimation(
          parent: _playController!,
          curve: Curves.easeInBack,
        ),
      );
      _playController?.reverse();
      _reversed = true;
    }
  }

  void _resetHorizontalTarget() {
    if (_reversed) {
      _offsetHorizontalAnimation = Tween<double>(
        begin: _leftOffset,
        end: widget.leftOffset,
      ).animate(
        CurvedAnimation(
          parent: _playHorizontalController!,
          curve: Curves.easeOutBack,
        ),
      );
      _playHorizontalController?.forward();
      _reversed = false;
    } else {
      _offsetHorizontalAnimation = Tween<double>(
        begin: widget.leftOffset,
        end: _leftOffset,
      ).animate(
        CurvedAnimation(
          parent: _playHorizontalController!,
          curve: Curves.easeInBack,
        ),
      );
      _playHorizontalController?.reverse();
      _reversed = true;
    }
  }

  Future<void> _close() async {
    _cancelT();

    if (widget.dismissDirectly) {
      widget.finished();
      return;
    }

    if (_reversed) {
      _offsetAnimation = Tween<double>(
        begin: _offset,
        end: begin,
      ).animate(
        CurvedAnimation(
          parent: _playController!,
          curve: Curves.linear,
        ),
      );
      try {
        await _playController?.forward();
        widget.finished();
      } catch (e) {
        widget.finished();
      }
      return;
    } else {
      _offsetAnimation = Tween<double>(
        begin: begin,
        end: _offset,
      ).animate(
        CurvedAnimation(
          parent: _playController!,
          curve: Curves.linear,
        ),
      );
      try {
        await _playController?.reverse();
        widget.finished();
      } catch (e) {
        widget.finished();
      }
      return;
    }
  }

  Future<void> _horizontalClose() async {
    _cancelT();

    if (widget.dismissDirectly) {
      widget.finished();
      return;
    }

    _offsetHorizontalAnimation = Tween<double>(
      begin: _leftOffset,
      end: _leftOffset - childWidth,
    ).animate(
      CurvedAnimation(
        parent: _playHorizontalController!,
        curve: Curves.linear,
      ),
    );
    widget.finished();
    return;
  }

  void _readyDismissOverlay() {
    if (widget.keepDuration > 0) {
      _t = Timer(Duration(seconds: widget.keepDuration), _close);
    }
  }

  void _cancelT() {
    if (_t == null) return;
    _t?.cancel();
    _t = null;
  }
}
