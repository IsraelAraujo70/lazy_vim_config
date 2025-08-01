/**
 * Advanced Calculator Library - Modern ES2024+ Implementation
 * Mathematical operations with comprehensive validation and logging
 * @author Alternativa Desenvolvimento Team
 * @version 7.0.0
 * @license MIT
 */

class MathCalculator {
  constructor(precision = 10) {
    this.precision = precision;
    this.history = [];
    this.debug = false;
  }

  /**
   * Addition operation with validation
   * @param {number} a - First number
   * @param {number} b - Second number
   * @returns {number} Sum result
   */
  add(a, b) {
    this._validateNumbers(a, b);
    const result = a + b;
    this._logOperation("ADD", a, b, result);

    if (this.debug) {
      console.log(`Debug: Addition performed ${a} + ${b} = ${result}`);
    }

    return result;
  }

  /**
   * Subtraction operation
   * @param {number} a - Minuend
   * @param {number} b - Subtrahend
   * @returns {number} Difference result
   */
  subtract(a, b) {
    this._validateNumbers(a, b);
    const result = a - b;
    this._logOperation("SUBTRACT", a, b, result);
    return result;
  }

  /**
   * Multiplication with optimizations
   * @param {number} a - First factor
   * @param {number} b - Second factor
   * @returns {number} Product result
   */
  multiply(a, b) {
    this._validateNumbers(a, b);

    // Fast path optimizations
    if (a === 0 || b === 0) return 0;
    if (a === 1) return b;
    if (b === 1) return a;

    const result = a * b;
    this._logOperation("MULTIPLY", a, b, result);
    return result;
  }

  /**
   * Division with zero-check and precision handling
   * @param {number} dividend - Number to be divided
   * @param {number} divisor - Number to divide by
   * @returns {number} Quotient result
   */
  divide(dividend, divisor) {
    this._validateNumbers(dividend, divisor);

    if (divisor === 0) {
      throw new Error("Division by zero is not allowed");
    }

    const result = dividend / divisor;
    const roundedResult = parseFloat(result.toFixed(this.precision));
    this._logOperation("DIVIDE", dividend, divisor, roundedResult);
    return roundedResult;
  }

  /**
   * Power operation (exponentiation)
   * @param {number} base - Base number
   * @param {number} exponent - Exponent
   * @returns {number} Power result
   */
  power(base, exponent) {
    this._validateNumbers(base, exponent);

    if (exponent === 0) return 1;
    if (base === 0 && exponent < 0) {
      throw new Error("Cannot raise 0 to negative power");
    }
    if (base === 1) return 1; // Optimization: 1^n is always 1
    if (base === -1) return exponent % 2 === 0 ? 1 : -1; // Optimization for -1

    const result = Math.pow(base, exponent);
    this._logOperation("POWER", base, exponent, result);
    return result;
  }

  /**
   * Calculate factorial
   * @param {number} n - Non-negative integer
   * @returns {number} Factorial result
   */
  factorial(n) {
    if (!Number.isInteger(n) || n < 0) {
      throw new Error("Factorial requires non-negative integer");
    }

    if (n <= 1) return 1;

    let result = 1;
    for (let i = 2; i <= n; i++) {
      result *= i;
    }

    this._logOperation("FACTORIAL", n, null, result);
    return result;
  }

  /**
   * Calculate square root with Newton's method fallback
   * @param {number} n - Non-negative number
   * @returns {number} Square root result
   */
  sqrt(n) {
    if (typeof n !== "number" || n < 0) {
      throw new Error("Square root requires non-negative number");
    }

    if (n === 0 || n === 1) {
      this._logOperation("SQRT", n, null, n);
      return n;
    }

    const result = Math.sqrt(n);
    this._logOperation("SQRT", n, null, result);
    return result;
  }

  // === GEOMETRY AND AREA CALCULATIONS ===

  /**
   * Calculate circle area
   * @param {number} radius - Circle radius
   * @returns {number} Area result
   */
  circleArea(radius) {
    if (typeof radius !== "number" || radius < 0) {
      throw new Error("Radius must be a positive number");
    }

    const result = Math.PI * radius * radius;
    console.log(`🔵 Circle area: π × ${radius}² = ${result.toFixed(4)}`);
    return result;
  }

  /**
   * Calculate rectangle perimeter
   * @param {number} width - Rectangle width
   * @param {number} height - Rectangle height
   * @returns {number} Perimeter result
   */
  rectanglePerimeter(width, height) {
    this._validateNumbers(width, height);

    if (width <= 0 || height <= 0) {
      throw new Error("Dimensions must be positive");
    }

    const result = 2 * (width + height);
    console.log(
      `📐 Rectangle perimeter: 2 × (${width} + ${height}) = ${result}`,
    );
    return result;
  }

  // === TRIGONOMETRY ===

  /**
   * Sine function
   * @param {number} angle - Angle in radians
   * @returns {number} Sine value
   */
  sin(angle) {
    this._validateNumbers(angle);
    const result = Math.sin(angle);
    console.log(`📐 sin(${angle}) = ${result.toFixed(6)}`);
    return result;
  }

  /**
   * Cosine function
   * @param {number} angle - Angle in radians
   * @returns {number} Cosine value
   */
  cos(angle) {
    this._validateNumbers(angle);
    const result = Math.cos(angle);
    console.log(`📐 cos(${angle}) = ${result.toFixed(6)}`);
    return result;
  }

  /**
   * Convert degrees to radians
   * @param {number} degrees - Angle in degrees
   * @returns {number} Angle in radians
   */
  degreesToRadians(degrees) {
    this._validateNumbers(degrees);
    const result = degrees * (Math.PI / 180);
    console.log(`🔄 ${degrees}° → ${result.toFixed(6)} rad`);
    return result;
  }

  // === STATISTICAL METHODS ===

  /**
   * Calculate mean (average) of numbers
   * @param {number[]} numbers - Array of numbers
   * @returns {number} Mean value
   */
  mean(numbers) {
    if (!Array.isArray(numbers) || numbers.length === 0) {
      throw new Error("Mean requires non-empty array of numbers");
    }
    
    const sum = numbers.reduce((acc, num) => {
      this._validateNumbers(num);
      return acc + num;
    }, 0);
    
    const result = sum / numbers.length;
    console.log(`📊 Mean of [${numbers.join(", ")}] = ${result.toFixed(4)}`);
    return result;
  }

  /**
   * Calculate median of numbers
   * @param {number[]} numbers - Array of numbers
   * @returns {number} Median value
   */
  median(numbers) {
    if (!Array.isArray(numbers) || numbers.length === 0) {
      throw new Error("Median requires non-empty array of numbers");
    }
    
    const sorted = [...numbers].sort((a, b) => a - b);
    const mid = Math.floor(sorted.length / 2);
    
    const result = sorted.length % 2 === 0
      ? (sorted[mid - 1] + sorted[mid]) / 2
      : sorted[mid];
    
    console.log(`📊 Median of [${numbers.join(", ")}] = ${result}`);
    return result;
  }

  // === UTILITY METHODS ===

  /**
   * Get calculation history
   * @returns {Array} History of operations
   */
  getHistory() {
    return [...this.history];
  }

  /**
   * Clear calculation history
   */
  clearHistory() {
    const count = this.history.length;
    this.history = [];
    console.log(`📋 History cleared (${count} operations removed)`);
  }

  /**
   * Set precision for results
   * @param {number} precision - Number of decimal places
   */
  setPrecision(precision) {
    if (!Number.isInteger(precision) || precision < 0) {
      throw new Error("Precision must be non-negative integer");
    }
    if (precision > 15) {
      console.warn("High precision values may cause floating point errors");
    }
    this.precision = precision;
    console.log(`Precision set to ${precision} decimal places`);
  }

  // === PRIVATE METHODS ===

  /**
   * Validate input numbers
   * @private
   */
  _validateNumbers(...numbers) {
    for (const num of numbers) {
      if (typeof num !== "number" || !isFinite(num)) {
        throw new Error("All parameters must be finite numbers");
      }
    }
  }

  /**
   * Log operation to history and console
   * @private
   */
  _logOperation(operation, a, b, result) {
    const entry = {
      operation,
      operands: b !== null ? [a, b] : [a],
      result,
      timestamp: new Date().toISOString(),
    };

    this.history.push(entry);

    const symbol = this._getOperationSymbol(operation);
    const operandStr = b !== null ? `${a} ${symbol} ${b}` : `${symbol}(${a})`;
    console.log(`🧮 ${operandStr} = ${result}`);
  }

  /**
   * Get symbol for operation
   * @private
   */
  _getOperationSymbol(operation) {
    const symbols = {
      ADD: "+",
      SUBTRACT: "-",
      MULTIPLY: "×",
      DIVIDE: "÷",
      POWER: "^",
      FACTORIAL: "!",
      SQRT: "√",
    };
    return symbols[operation] || operation;
  }
}

// Export for use
const calculator = new MathCalculator();
const debugCalculator = new MathCalculator();
debugCalculator.debug = true;

// Legacy function exports for compatibility
const somar = (a, b) => calculator.add(a, b);
const subtrair = (a, b) => calculator.subtract(a, b);
const multiplicar = (a, b) => calculator.multiply(a, b);
const dividir = (a, b) => calculator.divide(a, b);
const fatorial = (n) => calculator.factorial(n);

module.exports = {
  MathCalculator,
  calculator,
  debugCalculator,
  somar,
  subtrair,
  multiplicar,
  dividir,
  fatorial,
};

