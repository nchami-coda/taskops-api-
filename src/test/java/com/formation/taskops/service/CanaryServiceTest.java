package com.formation.taskops.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class CanaryServiceTest {

    @Test
    @DisplayName("a 0% : utiliserNouvelleVersion() renvoie toujours false")
    void aZeroPourcent_renvoieToujoursFalse() {
        CanaryService canary = new CanaryService(0);

        for (int i = 0; i < 20; i++) {
            assertThat(canary.utiliserNouvelleVersion()).isFalse();
        }
        assertThat(canary.getPourcentage()).isEqualTo(0);
    }

    @Test
    @DisplayName("a 100% : utiliserNouvelleVersion() renvoie toujours true")
    void aCentPourcent_renvoieToujoursTrue() {
        CanaryService canary = new CanaryService(100);

        for (int i = 0; i < 20; i++) {
            assertThat(canary.utiliserNouvelleVersion()).isTrue();
        }
        assertThat(canary.getPourcentage()).isEqualTo(100);
    }

    @Test
    @DisplayName("le pourcentage est borne entre 0 et 100")
    void bornageDefensif() {
        assertThat(new CanaryService(-10).getPourcentage()).isEqualTo(0);
        assertThat(new CanaryService(150).getPourcentage()).isEqualTo(100);
    }

    @Test
    @DisplayName("a 50% : le tirage varie sur un grand nombre d'appels")
    void aCinquantePourcent_leTirageVarie() {
        CanaryService canary = new CanaryService(50);

        long nombreDeVrai = 0;
        for (int i = 0; i < 200; i++) {
            if (canary.utiliserNouvelleVersion()) {
                nombreDeVrai++;
            }
        }
        // Sur 200 tirages a 50%, on attend un resultat ni jamais-vrai ni jamais-faux
        assertThat(nombreDeVrai).isBetween(50L, 150L);
    }
}