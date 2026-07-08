// PRICES are in cent * 10 to not have any comma values
// prices are given per 1 Million tokens.

import { DesignConfiguration } from '@ui/types/design-configuration';

export const TOKEN_AMOUNT_PER_PRICE = 1_000_000;
export const CENT_MULTIPLIER = 10;
export const PRICE_AND_CENT_MULTIPLIER = TOKEN_AMOUNT_PER_PRICE * CENT_MULTIPLIER;

export const DEFAULT_DESIGN_CONFIGURATION: DesignConfiguration = {
  primaryColor: '#00883A', // LMU Grün
  primaryTextColor: '#FFFFFF',
  secondaryColor: '#E6E6E7', // Sekundär Hellgrau
  secondaryTextColor: '#232323', // LMU Schwarz
};
