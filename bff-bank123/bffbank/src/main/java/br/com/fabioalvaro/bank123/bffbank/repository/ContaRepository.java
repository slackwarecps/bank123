package br.com.fabioalvaro.bank123.bffbank.repository;

import br.com.fabioalvaro.bank123.bffbank.model.Conta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ContaRepository extends JpaRepository<Conta, Integer> {
}