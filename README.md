# ERC20 Staking Contract

Este contrato permite a los usuarios stakear tokens ERC20 y ganar recompensas basadas en la cantidad de tokens stakeados y el tiempo transcurrido en bloques.

## 🚀 Características Principales

- **Stake de tokens ERC20**: Los usuarios pueden depositar tokens y comenzar a ganar recompensas por bloque.
- **Retiro de tokens**: Retira parcial o totalmente los tokens stakeados.
- **Reclamación de recompensas**: Recompensas acumuladas disponibles para reclamar en cualquier momento.
- **Cambio de tasa de recompensa**: El propietario puede ajustar la tasa de recompensa por bloque.
  
## 🔧 Funcionalidades Clave

### Comparación de Strings

Se incluye la función `compareStrings` que permite comparar dos strings utilizando `keccak256`. Este patrón es útil en Solidity ya que no existe una función nativa para comparar strings directamente. La función retorna `true` si los strings son equivalentes.

```solidity
function compareStrings(string memory string1, string memory string2) public pure returns (bool) {
    return keccak256(abi.encodePacked(string1)) == keccak256(abi.encodePacked(string2));
}
```
### Staking

- **stake(uint256 _amount)**: Permite a los usuarios depositar tokens en el contrato y empezar a acumular recompensas.

### Retiro de tokens

- **withdraw(uint256 _amount)**: Retira tokens stakeados y mantiene las recompensas pendientes.

### Reclamación de Recompensas

- **claimRewards()**: Reclama las recompensas acumuladas hasta el momento. Las recompensas se calculan en función de los bloques que el usuario ha stakeado.

## 📜 Requisitos

1. El token debe seguir el estándar ERC20.
2. Los usuarios deben aprobar previamente al contrato para gastar tokens en su nombre.

