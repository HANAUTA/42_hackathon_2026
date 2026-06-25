// ステッカーのオーバーレイデータ。位置はコンテナに対する相対座標(0.0〜1.0)。

class StickerOverlay {
  const StickerOverlay({
    required this.emoji,
    required this.x,
    required this.y,
    this.scale = 1.0,
  });

  final String emoji;
  // コンテナ幅に対する左端からの相対位置（0.0〜1.0）。
  final double x;
  // コンテナ高さに対する上端からの相対位置（0.0〜1.0）。
  final double y;
  final double scale;

  factory StickerOverlay.fromJson(Map<String, dynamic> json) => StickerOverlay(
        emoji: json['emoji'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      );

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'x': x,
        'y': y,
        'scale': scale,
      };

  StickerOverlay copyWith({double? x, double? y}) => StickerOverlay(
        emoji: emoji,
        x: x ?? this.x,
        y: y ?? this.y,
        scale: scale,
      );
}
