#include "processor.h"
#include "mmu.h"
#include "simif.h"
#include "disasm.h"

static processor_t* proc = nullptr;

extern "C"
{
    void spike_init()
    {
        if(proc == nullptr)
        {
            const char* isa = "rv32i";
            const char* priv = "m";
            proc = new processor_t(isa, priv, "none", nullptr, 0, false, stdout);
        }
    }

    void spike_step(int instr)
    {
        proc->step(1);
    }

    int spike_get_reg(int reg_idx)
    {
        return (int)proc->get_state()->XPR[reg_idx];
    }

    void spike_set_reg(int reg_idx, int val)
    {
        proc->get_state()->XPR.write(reg_idx, (reg_t)val);
    }

    int spike_get_pc()
    {
        return (int)proc->get_state()->pc;
    }

    void spike_write_mem(int addr, int data)
    {
        proc->get_mmu()->store_uint32(addr, data);
    }

    void spike_set_pc(int val)
    {
        proc->get_state()->pc = (reg_t)val;
    }
}