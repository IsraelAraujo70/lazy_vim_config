const somar = (a, b) => {
  // Improved function with input validation
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Both parameters must be numbers");
  }
  return a + b;
};

const subtract = (a, b) => {
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Both parameters must be numbers");
  }
  return a - b;
};

const multiply = (a, b) => {
  // Enhanced multiplication with error handling
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Both parameters must be numbers");
  }

  const result = a * b;

  // Handle special cases
  if (!isFinite(result)) {
    throw new Error("Result is not a finite number");
  }

  return result;
};

const divide = (a, b) => {
  if (typeof a !== "number" || typeof b !== "number") {
    throw new Error("Both parameters must be numbers");
  }
  if (b === 0) {
    throw new Error("Cannot divide by zero");
  }
  return a / b;
};

// Exponenciação

const exponentiation = (base, exponent) => {
  if (typeof base !== "number" || typeof exponent !== "number") {
    throw new Error("Both parameters must be numbers");
  }
  return Math.pow(base, exponent);
};
