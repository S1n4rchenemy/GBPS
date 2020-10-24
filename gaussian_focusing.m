function [w2, zR2, d2] = gaussian_focusing(w1, zR1, d1, f)
    w2 = sqrt(f^2 / (zR1^2 + (d1 - f)^2)) * w1;
    d2 = f^2 / (zR1^2 + (d1 - f)^2) * (d1 - f) + f;
    zR2 = (w2 / w1)^2 * zR1;
    