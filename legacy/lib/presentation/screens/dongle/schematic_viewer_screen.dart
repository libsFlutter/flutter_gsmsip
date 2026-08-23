import 'package:flutter/material.dart';
import '../../domain/models/dongle_type.dart';

/// Экран просмотра схемы донгла
class SchematicViewerScreen extends StatelessWidget {
  final DongleType? dongleType;

  const SchematicViewerScreen({
    super.key,
    this.dongleType,
  });

  @override
  Widget build(BuildContext context) {
    final type = dongleType ?? DongleType.differential;

    return Scaffold(
      appBar: AppBar(
        title: Text('${type.displayName} Circuit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // Export to PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF export coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Circuit Diagram
            _buildCircuitDiagram(type),
            
            const SizedBox(height: 24),
            
            // Components List
            _buildComponentsCard(type),
            
            const SizedBox(height: 16),
            
            // Function Description
            _buildFunctionCard(type),
            
            const SizedBox(height: 16),
            
            // Pinout
            _buildPinoutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircuitDiagram(DongleType type) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Circuit Diagram',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // ASCII-style circuit diagram
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  if (type == DongleType.differential) ...[
                    // Differential (4R+1C)
                    _buildDiagramLine('LEFT', '────R1────┬────────R3──── TIP (+)'),
                    _buildDiagramLine('', '             │'),
                    _buildDiagramLine('', '            C1'),
                    _buildDiagramLine('', '             │'),
                    _buildDiagramLine('RIGHT (-R)', '────R2────┴────────R4──── RING (-)'),
                    _buildDiagramLine('', ''),
                    _buildDiagramLine('GND', '─────────────●'),
                    _buildDiagramLine('', '             │'),
                    _buildDiagramLine('MIC', '─────────────●'),
                  ] else if (type == DongleType.monoLoopback) ...[
                    // Mono Loopback
                    _buildDiagramLine('LEFT', '───────────────────────────────────┐'),
                    _buildDiagramLine('', '                                      │'),
                    _buildDiagramLine('RIGHT', '────────┐                         │'),
                    _buildDiagramLine('', '         │                         │'),
                    _buildDiagramLine('', '        ┌┴┐                        │'),
                    _buildDiagramLine('', '        │ │ R3 47k                 │'),
                    _buildDiagramLine('', '        └┬┘                        │'),
                    _buildDiagramLine('', '         │                         │'),
                    _buildDiagramLine('GND', '─────────●─────────────────────────┤'),
                    _buildDiagramLine('', '         │                         │'),
                    _buildDiagramLine('', '        ┌┴┐                        │'),
                    _buildDiagramLine('', '        │ │ R4 10k                 │'),
                    _buildDiagramLine('', '        └┬┘                        │'),
                    _buildDiagramLine('MIC', '─────────●─────────────────────────┘'),
                  ] else ...[
                    // Stereo / Earphone-to-Mic
                    _buildDiagramLine('LEFT', '─────────────────────────●──────────┐'),
                    _buildDiagramLine('', '                          │           │'),
                    _buildDiagramLine('', '                         ┌┴┐          │'),
                    _buildDiagramLine('', '                         │ │ R1 10k   │'),
                    _buildDiagramLine('', '                         └┬┘          │'),
                    _buildDiagramLine('', '                          │           │'),
                    _buildDiagramLine('RIGHT', '──────────┐           │           │'),
                    _buildDiagramLine('', '           │           │           │'),
                    _buildDiagramLine('', '          ┌┴┐          │           │'),
                    _buildDiagramLine('', '          │ │ R2 10k   │           │'),
                    _buildDiagramLine('', '          └┬┘          │           │'),
                    _buildDiagramLine('', '           │           │           │'),
                    _buildDiagramLine('GND', '───────────●───────────┴───────────┤'),
                    _buildDiagramLine('', '           │                         │'),
                    _buildDiagramLine('MIC', '───────────●─────────────────────────┘'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentsCard(DongleType type) {
    List<Map<String, String>> components;
    
    if (type == DongleType.differential) {
      components = [
        {'name': 'R1, R2', 'value': '10kΩ', 'desc': 'Input impedance'},
        {'name': 'R3, R4', 'value': '10kΩ', 'desc': 'Output impedance'},
        {'name': 'C1', 'value': '100nF', 'desc': 'DC blocking capacitor'},
      ];
    } else if (type == DongleType.monoLoopback) {
      components = [
        {'name': 'R1', 'value': 'N/A', 'desc': 'Not used'},
        {'name': 'R2', 'value': 'N/A', 'desc': 'Not used'},
        {'name': 'R3', 'value': '47kΩ', 'desc': 'Mixing resistor'},
        {'name': 'R4', 'value': '10kΩ', 'desc': 'MIC bias resistor'},
      ];
    } else {
      components = [
        {'name': 'R1, R2', 'value': '10kΩ', 'desc': 'Input impedance'},
        {'name': 'R3', 'value': '47kΩ', 'desc': 'Mixing resistor'},
        {'name': 'R4', 'value': '10kΩ', 'desc': 'MIC bias resistor'},
      ];
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Components',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...components.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      c['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      c['value']!,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      c['desc']!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionCard(DongleType type) {
    String description;
    
    switch (type) {
      case DongleType.differential:
        description = 'Differential output: TIP - RING = L - (-R). '
            'DC blocking prevents offset on phone line. '
            'Impedance matched for 600Ω phone line.';
        break;
      case DongleType.monoLoopback:
        description = 'Mono loopback: L and R are mixed through resistors '
            'to produce a single mono signal for the MIC input.';
        break;
      case DongleType.stereoLoopback:
        description = 'Stereo loopback: L and R channels remain separate. '
            'No mixing occurs.';
        break;
      case DongleType.earphoneToMic:
        description = 'Earphone-to-Mic: Acoustic coupling where speaker '
            'output is physically coupled to microphone input.';
        break;
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Text(
                  'Function',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinoutCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TRRS Pinout (CTIA)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // TRRS diagram
            Center(
              child: Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // TRRS plug shape
                    Positioned(
                      left: 20,
                      top: 30,
                      child: Container(
                        width: 140,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    // Labels
                    Positioned(
                      left: 30,
                      top: 40,
                      child: _buildPinLabel('TIP', 'Left (L)'),
                    ),
                    Positioned(
                      left: 30,
                      top: 60,
                      child: _buildPinLabel('RING1', 'Right (R)'),
                    ),
                    Positioned(
                      left: 30,
                      top: 80,
                      child: _buildPinLabel('RING2', 'GND'),
                    ),
                    Positioned(
                      left: 30,
                      top: 100,
                      child: _buildPinLabel('SLEEVE', 'MIC'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pin table
            _buildPinRow('TIP', 'Left Channel (L)', 'Audio output'),
            _buildPinRow('RING1', 'Right Channel (R)', 'Audio output (inverted)'),
            _buildPinRow('RING2', 'Ground', 'Common ground'),
            _buildPinRow('SLEEVE', 'Microphone', 'Audio input'),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramLine(String label, String diagram) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              diagram,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinLabel(String ring, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ring,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPinRow(String pin, String signal, String function) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              pin,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(signal),
          ),
          Expanded(
            child: Text(
              function,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
