import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rotijugaad/theme/context_ext.dart';

typedef PlaceSelectedCallback = void Function(
  String address,
  double lat,
  double lng,
);

class PlacesAutocompleteField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool enabled;
  final PlaceSelectedCallback onPlaceSelected;

  const PlacesAutocompleteField({
    super.key,
    required this.title,
    required this.controller,
    required this.onPlaceSelected,
    this.focusNode,
    this.hintText = '',
    this.enabled = true,
  });

  @override
  State<PlacesAutocompleteField> createState() =>
      _PlacesAutocompleteFieldState();
}

class _PlacesAutocompleteFieldState extends State<PlacesAutocompleteField> {
  static const _apiKey = 'AIzaSyDkTDMXqZFjCYkpa1QPWCsZocpTlPcXvBk';

  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<_Prediction> _predictions = [];
  bool _loading = false;
  Timer? _debounce;
  bool _suppressSearch = false;

  late final FocusNode _ownFocusNode = FocusNode();
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _ownFocusNode;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    _effectiveFocusNode.removeListener(_onFocusChanged);
    _ownFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_effectiveFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), _removeOverlay);
    }
  }

  void _onTextChanged() {
    if (_suppressSearch) return;
    if (!_effectiveFocusNode.hasFocus) return;
    final text = widget.controller.text.trim();
    _debounce?.cancel();
    if (text.length < 2) {
      _removeOverlay();
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _fetchSuggestions(text),
    );
  }

  Future<void> _fetchSuggestions(String input) async {
    if (!mounted) return;
    setState(() => _loading = true);

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&key=$_apiKey'
      '&language=en'
      '&components=country:in',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] == 'OK') {
        final list = (data['predictions'] as List)
            .map(
              (p) => _Prediction(
                placeId: p['place_id'] as String,
                description: p['description'] as String,
              ),
            )
            .toList();
        if (!mounted) return;
        setState(() {
          _predictions = list;
          _loading = false;
        });
        _showOverlay();
      } else {
        if (!mounted) return;
        setState(() {
          _predictions = [];
          _loading = false;
        });
        _removeOverlay();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onPredictionTap(_Prediction prediction) async {
    _removeOverlay();
    _suppressSearch = true;
    widget.controller.text = prediction.description;
    _suppressSearch = false;
    _effectiveFocusNode.unfocus();

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=${prediction.placeId}'
      '&fields=formatted_address,geometry'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'OK') {
        final result = data['result'] as Map<String, dynamic>;
        final address =
            (result['formatted_address'] as String?) ?? prediction.description;
        final location =
            (result['geometry'] as Map<String, dynamic>)['location']
                as Map<String, dynamic>;
        final lat = (location['lat'] as num).toDouble();
        final lng = (location['lng'] as num).toDouble();

        _suppressSearch = true;
        widget.controller.text = address;
        _suppressSearch = false;

        widget.onPlaceSelected(address, lat, lng);
      }
    } catch (_) {}
  }

  void _showOverlay() {
    _removeOverlay();
    if (_predictions.isEmpty) return;

    final box = context.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(300, 72);

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _predictions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 1),
                  itemBuilder: (ctx, i) {
                    final pred = _predictions[i];
                    return InkWell(
                      onTap: () => _onPredictionTap(pred),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pred.description,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _effectiveFocusNode,
              enabled: widget.enabled,
              maxLines: 1,
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                ),
                counterText: '',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Prediction {
  final String placeId;
  final String description;
  const _Prediction({required this.placeId, required this.description});
}
