package com.omar.isdb62.pharmacy_management_backend.controller;

import com.omar.isdb62.pharmacy_management_backend.model.Generic;
import com.omar.isdb62.pharmacy_management_backend.service.GenericService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/generic")
public class GenericController {
    @Autowired
    private GenericService genericService;

    @GetMapping
    public List<Generic> getAll() {
        return genericService.getAll();
    }

//    @PostMapping
//    public Generic add(@RequestBody Generic generic) {
//        return genericService.save(generic);
//    }

    @PostMapping
    public Generic add(@RequestBody Generic generic) {
        return genericService.save(generic);
    }


    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        genericService.delete(id);
    }
}
