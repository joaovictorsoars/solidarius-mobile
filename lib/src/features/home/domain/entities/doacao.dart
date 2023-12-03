import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'doacao.g.dart';

@JsonSerializable()
class Doacao extends Equatable {
  final String nomeEstabelecimento;
  final String tipo;
  final String distancia;
  final String endereco;
  final bool isRetirando;
  final bool isRetirado;
  final double latitude;
  final double longitude;

  const Doacao({
    required this.nomeEstabelecimento,
    required this.tipo,
    required this.distancia,
    required this.endereco,
    this.isRetirando = false,
    this.isRetirado = false,
    required this.latitude,
    required this.longitude,
  });

  factory Doacao.fromJson(Map<String, dynamic> json) => _$DoacaoFromJson(json);

  Map<String, dynamic> toJson() => _$DoacaoToJson(this);

  @override
  List<Object?> get props => [
        nomeEstabelecimento,
        tipo,
        distancia,
        endereco,
        isRetirando,
        isRetirado,
        latitude,
        longitude,
      ];
}
