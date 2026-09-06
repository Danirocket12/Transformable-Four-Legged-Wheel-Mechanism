%% ====================================================
%% CALCULO DEL JACOBIANO — Rueda Transformable
%% J(alfa) = (x_co)(Leq) * [ sin(alfa + 60°)/c - sin(alfa)/u ]
%% Evaluación puntual para un (alfa, x_co, Leq) dados
%% ====================================================

%% Parámetros de entrada
x_co = input('Ingresa el valor de x_co: ');
Leq  = input('Ingresa el valor de Leq: ');
alfa = input('Ingresa el valor de alfa (grados): ');

beta = 60;   % ángulo fijo beta, en grados

%% Conversión a radianes
alfa_r = deg2rad(alfa);
beta_r = deg2rad(beta);

%% Cálculo de u y c por ley de cosenos
u = sqrt(x_co^2 + Leq^2 - 2*Leq*x_co*cos(alfa_r));
c = sqrt(x_co^2 + Leq^2 - 2*Leq*x_co*cos(alfa_r + beta_r));

%% Cálculo del Jacobiano
J = (x_co)*(Leq)*( sin(alfa_r + beta_r)/c - sin(alfa_r)/u );

%% Resultado en consola
fprintf('\n=== RESULTADO ===\n');
fprintf('x_co      = %.4f\n', x_co);
fprintf('Leq       = %.4f\n', Leq);
fprintf('alfa      = %.4f grados\n', alfa);
fprintf('beta      = %.4f grados\n', beta);
fprintf('u         = %.4f\n', u);
fprintf('c         = %.4f\n', c);
fprintf('J(alfa)   = %.6f\n', J);

if abs(J) < 1e-4
    fprintf('\n--> El punto está prácticamente en una SINGULARIDAD (J ≈ 0)\n');
end