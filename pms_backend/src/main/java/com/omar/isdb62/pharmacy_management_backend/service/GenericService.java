package com.omar.isdb62.pharmacy_management_backend.service;

import com.omar.isdb62.pharmacy_management_backend.model.Generic;
import com.omar.isdb62.pharmacy_management_backend.repository.GenericRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GenericService {

    @Autowired
    private GenericRepository genericRepository;

    public List<Generic> getAll() {
        return genericRepository.findAll();
    }

    public Generic save(Generic generic) {
        generic.setGeneric(generic.getGeneric());
        return genericRepository.save(generic);
    }

    public void delete(Long id) {
        genericRepository.deleteById(id);
    }
}
