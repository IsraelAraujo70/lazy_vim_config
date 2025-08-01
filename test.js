// Calculadora matemática avançada v5.1 - Sistema robusto com detecção de porta ativa!
const somar = (a, b) => {
  // Validação robusta e completa dos parâmetros de entrada
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Parâmetros devem ser números válidos para operação matemática");
  }
  
  // Verificação de valores especiais
  if (!isFinite(a) || !isFinite(b)) {
    throw new Error("Valores infinitos não são suportados na soma");
  }
  
  // Execução do cálculo da soma com precisão
  const resultado = a + b;
  
  // Sistema de log detalhado da operação matemática
  console.log(`➕ Operação: ${a} + ${b} = ${resultado}`);
  console.log(`🔢 Tipo de resultado: ${typeof resultado}`);
  console.log(`✅ Soma executada com precisão matemática!`);
  
  return resultado;
};

const subtract = (a, b) => {
  // Validação rigorosa e completa dos parâmetros de entrada
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Ambos os parâmetros devem ser números válidos para subtração");
  }
  
  // Verificação de valores especiais e edge cases
  if (!isFinite(a) || !isFinite(b)) {
    throw new Error("Valores infinitos não são suportados na subtração");
  }
  
  // Cálculo da subtração com verificações matemáticas
  const resultado = a - b;
  
  // Sistema de log detalhado e informativo da operação
  console.log(`➖ Subtração: ${a} - ${b} = ${resultado}`);
  console.log(`📊 Análise: ${resultado >= 0 ? 'resultado positivo' : 'resultado negativo'}`);
  console.log(`🔢 Magnitude: ${Math.abs(resultado)}`);
  console.log(`✅ Operação de subtração concluída com precisão!`);
  
  return resultado;
};

const multiply = (a, b) => {
  // Função de multiplicação com validação avançada
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Ambos os parâmetros devem ser números válidos");
  }
  
  // Verificação de casos especiais
  if (a === 0 || b === 0) {
    return 0;
  }
  
  const result = a * b;
  // Sistema de log melhorado com emojis
  console.log(`🧮 Multiplicação executada: ${a} × ${b} = ${result}`);
  console.log(`📊 Resultado calculado com precisão`);
  console.log(`✅ Operação de multiplicação finalizada com sucesso`);
  return result;
};

const divide = (a, b) => {
  // Validação completa de parâmetros de entrada
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Ambos os parâmetros devem ser números");
  }
  
  // Proteção contra divisão por zero
  if (b === 0) {
    throw new Error("Impossível dividir por zero - operação inválida");
  }
  
  // Verificar se é uma divisão exata
  const isExact = a % b === 0;
  
  // Executar operação de divisão
  const resultado = a / b;
  
  // Sistema de logging detalhado
  console.log(`➗ Divisão: ${a} ÷ ${b} = ${resultado}`);
  console.log(`🎯 Divisão ${isExact ? 'exata' : 'com resto'}`);
  console.log(`📐 Cálculo matemático finalizado`);
  
  return resultado;
};

// === OPERAÇÕES MATEMÁTICAS AVANÇADAS ===

const exponentiation = (base, exponent) => {
  // Validação completa dos parâmetros de entrada
  if (typeof base !== "number" || typeof exponent !== "number") {
    throw new Error("Ambos os parâmetros devem ser números válidos");
  }

  // Validação de casos especiais matemáticos
  if (base === 0 && exponent < 0) {
    throw new Error("Impossível elevar 0 a uma potência negativa");
  }
  
  // Caso especial: qualquer número elevado a 0
  if (exponent === 0) {
    console.log(`📊 Potenciação: ${base}^0 = 1 (regra matemática)`);
    return 1;
  }

  // Cálculo da potenciação
  const result = Math.pow(base, exponent);
  console.log(`🔢 Potenciação: ${base}^${exponent} = ${result}`);
  console.log(`✅ Operação de exponenciação concluída`);
  
  return result;
};


// Função para calcular fatorial
const factorial = (n) => {
  // Validação completa do parâmetro de entrada
  if (typeof n !== "number" || !Number.isInteger(n)) {
    throw new Error("O parâmetro deve ser um número inteiro");
  }

  // Verificação de números negativos
  if (n < 0) {
    throw new Error("Não é possível calcular fatorial de números negativos");
  }

  // Casos base do fatorial
  if (n === 0 || n === 1) {
    console.log(`📊 Fatorial base: ${n}! = 1`);
    return 1;
  }

  // Cálculo iterativo otimizado do fatorial
  let result = 1;
  console.log(`🔢 Iniciando cálculo do fatorial de ${n}`);
  
  for (let i = 2; i <= n; i++) {
    result *= i;
    console.log(`🔄 Passo ${i}: ${i}! = ${result}`);
  }

  console.log(`✅ Fatorial calculado: ${n}! = ${result}`);
  return result;
};

// Funções trigonométricas
const sin = (angle) => {
  // Validação rigorosa do parâmetro de entrada
  if (typeof angle !== "number") {
    throw new Error("O ângulo deve ser um número válido");
  }
  
  // Calcular seno com precisão
  const result = Math.sin(angle);
  console.log(`📐 sin(${angle}) = ${result}`);
  return result;
};

const cos = (angle) => {
  // Validação completa do parâmetro
  if (typeof angle !== "number") {
    throw new Error("O ângulo deve ser um número válido");
  }
  
  // Calcular cosseno com log detalhado
  const result = Math.cos(angle);
  console.log(`📐 cos(${angle}) = ${result}`);
  return result;
};

// Função para converter graus para radianos
const degreesToRadians = (degrees) => {
  // Validação rigorosa do parâmetro de entrada
  if (typeof degrees !== "number") {
    throw new Error("O valor deve ser um número válido em graus");
  }
  
  // Verificação de limites razoáveis
  if (degrees < -360 || degrees > 360) {
    console.warn(`⚠️ Ângulo ${degrees}° está fora do range comum (-360° a 360°)`);
  }
  
  // Conversão precisa com log informativo
  const radians = degrees * (Math.PI / 180);
  console.log(`🔄 Conversão: ${degrees}° → ${radians.toFixed(6)} radianos`);
  console.log(`📊 Equivalente: ${(radians / Math.PI).toFixed(4)}π radianos`);
  
  return radians;
};
