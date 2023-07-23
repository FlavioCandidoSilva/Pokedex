import 'package:flutter/material.dart';
import 'package:pokemon/db.dart'; // Import the PokemonDatabase class

class CadastroPokemonScreen extends StatefulWidget {
  @override
  _CadastroPokemonScreenState createState() => _CadastroPokemonScreenState();
}

class _CadastroPokemonScreenState extends State<CadastroPokemonScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Novo Pokémon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome do Pokémon'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Tipo do Pokémon'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Get the Pokémon data from the text fields
                String name = _nameController.text;
                String type = _typeController.text;
                // Create a new map with the Pokémon data
                Map<String, dynamic> newPokemon = {
                  'name': name,
                  'type': [
                    type
                  ], // Assuming the type is a list (as in the pokedex data)
                  // ... (other fields if needed)
                };
                // Return the new Pokémon data to the previous screen (HomeScreen)
                Navigator.pop(context, newPokemon);
              },
              child: Text('Confirmar'),
            )
          ],
        ),
      ),
    );
  }

  void _cadastrarNovoPokemon() async {
    String name = _nameController.text;
    String type = _typeController.text;
    print('Cadastrando novo Pokémon...');

    if (name.isNotEmpty && type.isNotEmpty) {
      PokemonDB newPokemon = PokemonDB(name: name, type: type);

      int id = await PokemonDatabase.instance.create(newPokemon);

      Navigator.pop(context, newPokemon);
      if (id != null) {
        print('pokemon cadastrado com sucesso');
      } else {
        // Ocorreu um erro ao cadastrar o Pokémon
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro'),
              content: Text('Ocorreu um erro ao cadastrar o Pokémon.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Ok'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Exibir uma mensagem caso algum campo esteja vazio
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Campos obrigatórios'),
            content: Text('Por favor, preencha todos os campos.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }
}
